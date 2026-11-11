#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 07 · O primeiro pipeline
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  escrever um .gitlab-ci.yml, validar contra o schema oficial e ver os jobs que ele cria
#  EXECUTE   bash modulos/07-gitlab-ci-fundamentos/exemplos/01-primeiro-pipeline.sh
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

cp "$CURSO/modulos/07-gitlab-ci-fundamentos/exemplos/pipelines/basico.yml" .gitlab-ci.yml
passo "1. O pipeline"
grep -v '^#' .gitlab-ci.yml

passo "2. Validação contra o schema oficial do GitLab CI"
if command -v check-jsonschema >/dev/null; then
    check-jsonschema --builtin-schema vendor.gitlab-ci .gitlab-ci.yml
else
    echo "(pip install check-jsonschema — ou, no GitLab: glab ci lint)"
fi
mostra glab ci lint

passo "3. O que o GitLab vai montar: stages, jobs e dependências"
python3 "$CURSO/ferramentas/lib/yaml2json.py" .gitlab-ci.yml | jq -r '
  . as $c | ($c.stages // ["build","test","deploy"]) as $st
  | $st[] as $s | "stage \($s): " + ([$c | to_entries[] | select(.value | type=="object" and has("script"))
      | select((.value.stage // "test") == $s) | .key + (if .value.needs then " (needs: \(.value.needs | join(",")))" else "" end)] | join(", "))'

passo "4. Rodando o script do job 'compilar' como o runner faria"
export CI_COMMIT_SHORT_SHA=a1b2c3d4
python3 "$CURSO/ferramentas/lib/yaml2json.py" .gitlab-ci.yml | jq -r '.compilar.script[]' | while IFS= read -r cmd; do
    echo "\$ $cmd"; bash -c "$cmd"
done
cat dist/app.txt
