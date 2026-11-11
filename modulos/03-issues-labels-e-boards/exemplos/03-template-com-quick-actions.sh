#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 03 · Templates que já aplicam labels
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  criar templates de issue com quick actions e ver o que cada um faz ao ser usado
#  EXECUTE   bash modulos/03-issues-labels-e-boards/exemplos/03-template-com-quick-actions.sh
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

mkdir -p .gitlab/issue_templates
cat > .gitlab/issue_templates/Bug.md <<'MD'
## Passos para reproduzir
1.

## Comportamento esperado

## Comportamento atual

/label ~bug ~"status::triagem"
MD
cat > .gitlab/issue_templates/Seguranca.md <<'MD'
## O que você encontrou
(não publique dados de exploração aqui)

/label ~"segurança"
/confidential
MD
for t in .gitlab/issue_templates/*.md; do
    passo "$(basename "$t" .md)"
    echo "quick actions aplicadas ao criar:"
    grep '^/' "$t" | sed 's/^/   /'
done
echo
echo "No GitLab: New issue → Description → Choose a template. 'Default.md' é aplicado sozinho."
