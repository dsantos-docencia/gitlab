#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 08 · Ambientes, deploy manual e um deploy por vez
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ler um pipeline com matriz, cache, extends e ambiente, validá-lo e listar como ele implanta
#  EXECUTE   bash modulos/08-gitlab-ci-avancado/exemplos/03-ambientes-e-deploy.sh
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

cp "$CURSO/modulos/08-gitlab-ci-avancado/exemplos/pipelines/matriz-cache-ambientes.yml" .gitlab-ci.yml
passo "Validação contra o schema oficial"
command -v check-jsonschema >/dev/null && check-jsonschema --builtin-schema vendor.gitlab-ci .gitlab-ci.yml || echo "(instale check-jsonschema)"
passo "Como ele implanta"
python3 "$CURSO/ferramentas/lib/yaml2json.py" .gitlab-ci.yml | jq -r '
  to_entries[] | select(.value | type == "object" and has("environment")) | .key as $j | .value |
  "job \($j): ambiente=\(.environment.name) url=\(.environment.url) um-por-vez=\(.resource_group) quando=\(.rules[0].when // "automático")"'
passo "Chave de cache (muda quando o package-lock.json muda)"
python3 "$CURSO/ferramentas/lib/yaml2json.py" .gitlab-ci.yml | jq -c '.[".node"].cache'
