#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 06 · Proteção como código
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  aplicar a proteção recomendada da main e das tags v* pela API, de forma idempotente
#  EXECUTE   bash modulos/06-branches-e-tags-protegidas/exemplos/02-proteger-como-codigo.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/06-branches-e-tags-protegidas/exemplos/02-proteger-como-codigo.sh   (GitLab de verdade)
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

# --- glab: simulado por padrão; o de verdade com GLAB_REAL=1 ----------------
# Simulado = offline, sem conta, nada é criado; cada chamada fica registrada.
if [[ "${GLAB_REAL:-0}" == 1 ]]; then
    : "${LAB_PROJETO:?defina LAB_PROJETO=seu-usuario/lab-gitlab (veja laboratorio/)}"
    glab auth status >/dev/null 2>&1 || { echo "rode 'glab auth login' antes" >&2; exit 1; }
else
    # shellcheck source=/dev/null
    source "$CURSO/ferramentas/lib/glab-simulado.sh"
    LAB_PROJETO='aluno/laboratorio'
fi
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

P="$(enc "$LAB_PROJETO")"
passo "main: push só por MR (ninguém), merge Developers+, sem force push"
if glab api "projects/$P/protected_branches/main" >/dev/null 2>&1; then
    echo "(já protegida: desprotegemos para aplicar os níveis novos — a API não altera níveis com PATCH)"
    mostra glab api -X DELETE "projects/$P/protected_branches/main"
fi
mostra glab api -X POST "projects/$P/protected_branches" -f name=main \
    -F push_access_level=0 -F merge_access_level=30 -F allow_force_push=false
passo "tags v*: só Maintainers criam (o * vai codificado: v%2A)"
if glab api "projects/$P/protected_tags/$(enc 'v*')" >/dev/null 2>&1; then
    mostra glab api -X DELETE "projects/$P/protected_tags/$(enc 'v*')"
fi
mostra glab api -X POST "projects/$P/protected_tags" -f 'name=v*' -F create_access_level=40
passo "Regras de merge"
mostra glab api -X PUT "projects/$P" -F only_allow_merge_if_pipeline_succeeds=true \
    -F allow_merge_on_skipped_pipeline=false -F only_allow_merge_if_all_discussions_are_resolved=true
