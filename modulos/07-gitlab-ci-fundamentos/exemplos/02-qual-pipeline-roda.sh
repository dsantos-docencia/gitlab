#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 07 · Que pipeline roda em cada situação?
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  avaliar o workflow:rules em quatro cenários e entender a regra contra pipelines duplicados
#  EXECUTE   bash modulos/07-gitlab-ci-fundamentos/exemplos/02-qual-pipeline-roda.sh
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

# Avaliamos as regras do workflow como o GitLab faria (versão simplificada,
# só para as condições usadas aqui). A primeira regra que casar decide.
decidir() {   # decidir FONTE BRANCH TAG MR_ABERTO
    local CI_PIPELINE_SOURCE="$1" CI_COMMIT_BRANCH="$2" CI_COMMIT_TAG="$3" CI_OPEN_MERGE_REQUESTS="$4"
    if [[ "$CI_PIPELINE_SOURCE" == merge_request_event ]]; then echo "✔ cria (pipeline de MR)"; return; fi
    if [[ -n "$CI_COMMIT_BRANCH" && -n "$CI_OPEN_MERGE_REQUESTS" ]]; then echo "✘ não cria (o MR já tem pipeline)"; return; fi
    if [[ -n "$CI_COMMIT_BRANCH" ]]; then echo "✔ cria (pipeline de branch)"; return; fi
    if [[ -n "$CI_COMMIT_TAG" ]]; then echo "✔ cria (pipeline de tag)"; return; fi
    echo "✘ não cria (nenhuma regra casou)"
}
passo "Cenários"
printf '%-46s %s\n' "push na main, sem MR"                  "$(decidir push main '' '')"
printf '%-46s %s\n' "push em feature/login COM MR aberto"   "$(decidir push feature/login '' 'escola-dev/loja!7')"
printf '%-46s %s\n' "o mesmo push, visto pelo evento do MR" "$(decidir merge_request_event '' '' '')"
printf '%-46s %s\n' "push da tag v1.2.0"                    "$(decidir push '' v1.2.0 '')"
echo
echo "Sem a 2ª regra, o push com MR aberto geraria DOIS pipelines (branch + MR)."
