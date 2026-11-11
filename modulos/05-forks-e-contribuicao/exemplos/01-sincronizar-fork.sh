#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 05 · Mantendo um fork em dia
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  montar upstream, fork e clone locais e trazer as novidades com fetch + merge --ff-only
#  EXECUTE   bash modulos/05-forks-e-contribuicao/exemplos/01-sincronizar-fork.sh
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

passo "Original (upstream) e fork (origin), ambos bare como no GitLab"
git init -q --bare upstream.git
git clone -q upstream.git tmp 2>/dev/null
printf 'v1\n' > tmp/README.md && git -C tmp add . && git -C tmp commit -q -m "docs: v1" && git -C tmp push -q origin main
git clone -q --bare upstream.git fork.git
git clone -q fork.git meu-fork && cd meu-fork
mostra git remote add upstream ../upstream.git

passo "O original anda"
printf 'v2\n' >> ../tmp/README.md && git -C ../tmp commit -qam "docs: v2" && git -C ../tmp push -q origin main

passo "fetch upstream → merge --ff-only → push origin"
mostra git fetch -q upstream
mostra git merge --ff-only upstream/main
mostra git push -q origin main
git log --oneline -1 origin/main | sed 's/^/fork agora em: /'
