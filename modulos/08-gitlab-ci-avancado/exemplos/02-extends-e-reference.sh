#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 08 · extends, listas e !reference
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver por que extends substitui listas e como o !reference resolve, resolvendo o merge à mão
#  EXECUTE   bash modulos/08-gitlab-ci-avancado/exemplos/02-extends-e-reference.sh
# ============================================================================
set -euo pipefail
CURSO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

# --- Laboratório descartável --------------------------------------------------
# Pasta temporária apagada ao final; Git isolado (não lê nem altera o seu
# ~/.gitconfig); identidade fixa para os commits de demonstração.
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT; cd "$LAB"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$LAB/.gitconfig-lab" GIT_PAGER=cat
export GIT_AUTHOR_NAME='Ana Dev' GIT_AUTHOR_EMAIL='ana@exemplo.dev'
export GIT_COMMITTER_NAME='Ana Dev' GIT_COMMITTER_EMAIL='ana@exemplo.dev'
git config --global init.defaultBranch main
git config --global advice.detachedHead false

# --- glab simulado (offline): cada chamada é registrada, nada vai à internet -
# shellcheck source=/dev/null
source "$CURSO/ferramentas/lib/glab-simulado.sh"
export LAB_PROJETO='aluno/laboratorio'
passo()  { printf '\n== %s ==\n' "$*"; }
enc()    { jq -rn --arg v "$1" '$v | @uri'; }   # dono/projeto → dono%2Fprojeto (a API do GitLab exige)
# mostra: exibe o comando (com aspas só onde precisa) e depois o executa
mostra() {
    local a linha='$'
    for a in "$@"; do
        if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
            if [[ "$a" == *$'\n'* ]]; then a="'${a%%$'\n'*} …'"        # texto longo: só a 1ª linha
            elif [[ "$a" == *"'"* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
        fi
        linha+=" $a"
    done
    printf '%s\n' "$linha" >&2; "$@"   # o comando vai p/ stderr: dá para usar mostra … | jq
}

cat > .gitlab-ci.yml <<'YAML'
.base:
  image: alpine:3.22
  variables: {AMBIENTE: teste}
  script: [echo preparando]

job-extends:
  extends: .base
  variables: {DEBUG: "1"}
  script: [echo testando]

job-reference:
  extends: .base
  script:
    - !reference [.base, script]
    - echo testando
YAML
passo "O arquivo"; cat .gitlab-ci.yml
passo "Resolvendo como o GitLab: mapas se fundem, listas são SUBSTITUÍDAS"
python3 "$CURSO/ferramentas/lib/yaml2json.py" .gitlab-ci.yml | python3 -c '
import json, sys
c = json.load(sys.stdin)
def funde(a, b):
    r = dict(a)
    for k, v in b.items():
        r[k] = funde(r[k], v) if isinstance(v, dict) and isinstance(r.get(k), dict) else v
    return r
def ref(v):
    if isinstance(v, list):
        out = []
        for x in v:
            if isinstance(x, dict) and "!reference" in x:
                job, chave = x["!reference"]; out += c[job][chave]
            else: out.append(x)
        return out
    return v
for nome in ("job-extends", "job-reference"):
    j = funde(c[c[nome]["extends"]], {k: v for k, v in c[nome].items() if k != "extends"})
    j["script"] = ref(j["script"])
    print(nome + ": variables=" + json.dumps(j["variables"]) + " script=" + json.dumps(j["script"], ensure_ascii=False))
'
echo
echo "job-extends perdeu 'echo preparando' (lista substituída); job-reference manteve, via !reference."
