#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 11 · REST com paginação × GraphQL
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  listar os projetos de um grupo com paginação e obter contagens com uma única consulta GraphQL
#  EXECUTE   bash modulos/11-api-automacao-e-administracao/exemplos/01-paginacao-e-graphql.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/11-api-automacao-e-administracao/exemplos/01-paginacao-e-graphql.sh   (GitLab de verdade)
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

GRUPO="${LAB_GRUPO:-escola-dev}"
passo "REST: todos os projetos do grupo e subgrupos (todas as páginas)"
echo "\$ glab api --paginate 'groups/$GRUPO/projects?include_subgroups=true&per_page=100'"
glab api --paginate "groups/$(enc "$GRUPO")/projects?include_subgroups=true&per_page=100" |
    jq -r '.[] | "  \(.path_with_namespace)\t\(.visibility)\(if .archived then "\t(arquivado)" else "" end)"'
passo "GraphQL: só os números que interessam, num pedido só"
cat > consulta.graphql <<'GQL'
query($caminho: ID!) {
  currentUser { username }
  project(fullPath: $caminho) {
    issues(state: opened) { count }
    mergeRequests(state: opened) { count }
  }
}
GQL
cat consulta.graphql
glab api graphql -f query="$(cat consulta.graphql)" -f caminho="$LAB_PROJETO" |
    jq -r '.data | "  quem consulta: \(.currentUser.username) · issues abertas: \(.project.issues.count) · MRs abertos: \(.project.mergeRequests.count)"'
