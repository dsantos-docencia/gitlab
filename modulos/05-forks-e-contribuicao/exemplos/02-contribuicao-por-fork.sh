#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 05 · Uma contribuição completa por fork
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  fork, branch, commit, push e MR para o projeto original com o glab
#  EXECUTE   bash modulos/05-forks-e-contribuicao/exemplos/02-contribuicao-por-fork.sh
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

passo "1. Fork (no real, o glab cria o fork e configura origin/upstream)"
mostra glab repo fork escola-dev/loja --clone=false
git init -q --bare fork.git && git clone -q fork.git loja 2>/dev/null && cd loja
printf '# Loja\nInstalacao facil.\n' > README.md && git add . && git commit -q -m "docs: base" && git push -q origin main
passo "2. Branch focada"
mostra git switch -c docs/acentuacao
sed -i.bak 's/Instalacao facil/Instalação fácil/' README.md && rm -f README.md.bak
git commit -qam "docs: corrige acentuação no README"
passo "3. Push no fork e MR para o original"
mostra git push -q -u origin docs/acentuacao
mostra glab mr create --target-project escola-dev/loja --source-branch docs/acentuacao --target-branch main \
    --title "docs: corrige acentuação no README" --description "Só acentuação; sem mudança de código." --allow-collaboration
chamadas_glab
