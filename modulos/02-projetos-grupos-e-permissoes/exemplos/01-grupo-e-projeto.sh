#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 02 · Criando grupo e projeto
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  criar grupo, subgrupo e projeto pela API e pelo glab, e publicar um repositório local
#  EXECUTE   bash modulos/02-projetos-grupos-e-permissoes/exemplos/01-grupo-e-projeto.sh
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

passo "Grupo de topo e subgrupo (API)"
mostra glab api -X POST groups -f name="Escola Dev" -f path=escola-dev -f visibility=private
mostra glab api -X POST groups -f name=Backend -f path=backend -F parent_id=901 -f visibility=private

passo "Projeto no subgrupo (glab)"
mostra glab repo create api --group escola-dev/backend --private --description "API da Escola Dev" --defaultBranch main

passo "Repositório local apontando para ele"
git init -q api && cd api
printf '# API\n' > README.md && git add . && git commit -q -m "chore: estrutura inicial"
mostra git remote add origin git@gitlab.com:escola-dev/backend/api.git
git remote -v
echo "(no GitLab real: git push -u origin main — e um push para caminho inexistente CRIA o projeto)"

passo "Registro"
chamadas_glab
