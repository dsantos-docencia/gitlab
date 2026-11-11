#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 03 · Filas de trabalho com a API
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  montar filas úteis com filtros da API: triagem, parados, bugs por prioridade
#  EXECUTE   bash modulos/03-issues-labels-e-boards/exemplos/02-filas-de-trabalho.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/03-issues-labels-e-boards/exemplos/02-filas-de-trabalho.sh   (GitLab de verdade)
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

caminho="$(enc "$LAB_PROJETO")"
passo "Triagem: abertos sem responsável"
glab api "projects/$caminho/issues?state=opened&assignee_id=None&per_page=100" |
    jq -r '.[] | "#\(.iid)  \(.title)"'
passo "Parados há mais tempo"
glab api "projects/$caminho/issues?state=opened&order_by=updated_at&sort=asc&per_page=3" |
    jq -r '.[] | "\(.updated_at[:10])  #\(.iid) \(.title)"'
passo "Bugs, agrupados pelo label de prioridade (escopo prioridade::)"
glab api "projects/$caminho/issues?state=opened&labels=bug&per_page=100" |
    jq -r 'map(select(.labels | index("bug")))   # o GitLab já filtrou; repetimos aqui por garantia
           | group_by((.labels[] | select(startswith("prioridade::"))) // "prioridade::sem") | .[] | "\((.[0].labels[] | select(startswith("prioridade::"))) // "prioridade::sem"): \(map("#\(.iid)") | join(" "))"'
