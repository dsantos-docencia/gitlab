#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Projeto 03 · Verificador de componentes de CI/CD
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Confere, antes do push, o que o GitLab só reclamaria ao montar o pipeline
#  de quem usa o componente (Módulo 08):
#    • dois documentos YAML: spec  ---  corpo
#    • toda entrada tem description; type válido; default do tipo certo
#    • toda $[[ inputs.X ]] usada no corpo foi declarada
#    • toda entrada declarada é usada
#    • nenhuma imagem sem tag ou em :latest
#
#  USO     verificar-componente.sh templates/*.yml
#  SAÍDA   0 = tudo certo · 1 = problemas (listados) · 2 = uso incorreto
#  REQUER  python3 com PyYAML
# ============================================================================
set -euo pipefail
(( $# )) || { echo "uso: $0 templates/arquivo.yml [...]" >&2; exit 2; }
for f in "$@"; do [[ -f "$f" ]] || { echo "erro: não encontrado: $f" >&2; exit 2; }; done

python3 - "$@" <<'PY'
import re, sys, yaml

class Carregador(yaml.SafeLoader):
    pass
# Tags do GitLab (!reference) não são YAML padrão: aceitamos qualquer uma.
Carregador.add_multi_constructor("!", lambda l, s, n: l.construct_sequence(n) if isinstance(n, yaml.SequenceNode) else l.construct_scalar(n))

TIPOS = {"string": str, "number": (int, float), "boolean": bool, "array": list}
USO = re.compile(r"\$\[\[\s*inputs\.([A-Za-z0-9_-]+)")

def imagens(no):
    if isinstance(no, dict):
        for k, v in no.items():
            if k == "image":
                yield v if isinstance(v, str) else (v or {}).get("name", "")
            else:
                yield from imagens(v)
    elif isinstance(no, list):
        for v in no:
            yield from imagens(v)

problemas_total = 0
for caminho in sys.argv[1:]:
    texto = open(caminho, encoding="utf-8").read()
    problemas = []
    try:
        docs = list(yaml.load_all(texto, Loader=Carregador))
    except yaml.YAMLError as e:
        docs, problemas = [], [f"YAML inválido: {e}".splitlines()[0]]
    if docs and (len(docs) != 2 or not isinstance(docs[0], dict) or "spec" not in docs[0]):
        problemas.append("esperados 2 documentos: 'spec:' --- corpo")
    elif docs:
        entradas = (docs[0]["spec"] or {}).get("inputs") or {}
        corpo = texto.split("\n---", 1)[1]
        for nome, e in entradas.items():
            e = e or {}
            if not e.get("description"):
                problemas.append(f"entrada '{nome}' sem description")
            tipo = e.get("type", "string")
            if tipo not in TIPOS:
                problemas.append(f"entrada '{nome}': type inválido '{tipo}'")
            elif "default" in e and not (isinstance(e["default"], TIPOS[tipo]) and not (tipo == "number" and isinstance(e["default"], bool))):
                problemas.append(f"entrada '{nome}': default {e['default']!r} não é {tipo}")
        usadas = set(USO.findall(corpo))
        for nome in sorted(usadas - set(entradas)):
            problemas.append(f"usa inputs.{nome}, que não foi declarada")
        for nome in sorted(set(entradas) - usadas):
            problemas.append(f"entrada '{nome}' declarada e nunca usada")
        for img in imagens(docs[1]):
            base = img.rsplit("/", 1)[-1]
            if ":" not in base and "@" not in base:
                problemas.append(f"imagem sem versão: {img}")
            elif base.endswith(":latest"):
                problemas.append(f"imagem em :latest: {img}")
    if problemas:
        for p in problemas:
            print(f"✘ {caminho}: {p}")
    else:
        print(f"✔ {caminho}")
    problemas_total += len(problemas)
sys.exit(1 if problemas_total else 0)
PY
