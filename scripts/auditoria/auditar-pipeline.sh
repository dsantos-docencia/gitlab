#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/auditoria/auditar-pipeline.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Revisão estática de .gitlab-ci.yml — o que o schema aceita, mas um revisor
#  experiente recusaria (Módulos 07, 08 e 10):
#    • imagem/serviço sem versão ou em :latest
#    • include: project sem ref fixo · include: remote · componente @~latest
#    • variável com nome de segredo e valor escrito no próprio YAML
#    • CI_DEBUG_TRACE ligado (imprime variáveis mascaradas no log!)
#    • job com environment de produção sem rules/when: manual
#
#  USO     auditar-pipeline.sh [.gitlab-ci.yml ...]   (padrão: ./.gitlab-ci.yml)
#  SAÍDA   0 sem achados · 1 achados · 2 uso   ·   REQUER python3 + PyYAML
# ============================================================================
set -euo pipefail
(( $# )) || set -- .gitlab-ci.yml
for f in "$@"; do [[ -f "$f" ]] || { echo "erro: não encontrado: $f" >&2; exit 2; }; done

python3 - "$@" <<'PY'
import re, sys, yaml

class Carregador(yaml.SafeLoader):
    pass
Carregador.add_multi_constructor("!", lambda l, s, n: l.construct_sequence(n) if isinstance(n, yaml.SequenceNode) else l.construct_scalar(n))
# O YAML 1.1 lê "on"/"off" como booleano; para chaves isso só atrapalha.
Carregador.yaml_implicit_resolvers = {k: [r for r in v if r[0] != "tag:yaml.org,2002:bool"] for k, v in Carregador.yaml_implicit_resolvers.items()}

RESERVADAS = {"default", "include", "stages", "variables", "workflow", "image", "services", "cache", "before_script", "after_script", "spec"}
SEGREDO = re.compile(r"TOKEN|SENHA|PASSWORD|SECRET|PRIVATE_KEY|API_KEY", re.I)

def sem_versao(img):
    nome = img if isinstance(img, str) else (img or {}).get("name", "")
    base = nome.rsplit("/", 1)[-1]
    if "$" in nome:  return None                       # vem de variável: não dá para julgar
    if "@" in base:  return None                       # digest: o melhor caso
    if ":" not in base: return f"imagem sem versão: {nome}"
    if base.endswith(":latest"): return f"imagem em :latest: {nome}"
    return None

def variaveis(onde, vs, achados):
    for k, v in (vs or {}).items():
        valor = v.get("value") if isinstance(v, dict) else v
        if SEGREDO.search(k) and isinstance(valor, str) and valor and not valor.startswith("$"):
            achados.append(f"{onde}: variável {k} com valor no YAML — use variável de CI/CD mascarada")
        if k == "CI_DEBUG_TRACE" and str(valor).lower() == "true":
            achados.append(f"{onde}: CI_DEBUG_TRACE ligado expõe variáveis mascaradas no log")

total = 0
for caminho in sys.argv[1:]:
    achados = []
    cfg = yaml.load(open(caminho, encoding="utf-8"), Loader=Carregador) or {}
    incs = cfg.get("include", [])
    for inc in (incs if isinstance(incs, list) else [incs]):
        if isinstance(inc, dict):
            if "project" in inc and not inc.get("ref"):
                achados.append(f"include: project {inc['project']} sem ref fixo")
            if "remote" in inc:
                achados.append(f"include: remote {inc['remote']} — conteúdo fora do seu controle")
            if "component" in inc and re.search(r"@(~latest|main|master)$", inc["component"]):
                achados.append(f"componente sem versão fixa: {inc['component']}")
    variaveis("global", cfg.get("variables"), achados)
    escopos = [("global", cfg)] + [("default", cfg.get("default") or {})]
    escopos += [(f"job {n}", j) for n, j in cfg.items() if n not in RESERVADAS and isinstance(j, dict)]
    for onde, j in escopos:
        for img in ([j["image"]] if "image" in j else []) + list(j.get("services") or []):
            m = sem_versao(img)
            if m: achados.append(f"{onde}: {m}")
        if onde.startswith("job "):
            variaveis(onde, j.get("variables"), achados)
            amb = j.get("environment")
            nome_amb = amb if isinstance(amb, str) else (amb or {}).get("name", "")
            if re.match(r"prod", nome_amb or "", re.I) and "rules" not in j and j.get("when") != "manual":
                achados.append(f"{onde}: implanta em '{nome_amb}' sem rules nem when: manual")
    for a in achados:
        print(f"✘ {caminho}: {a}")
    if not achados:
        print(f"✔ {caminho}")
    total += len(achados)
sys.exit(1 if total else 0)
PY
