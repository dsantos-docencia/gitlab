#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 10 · Um segredo no histórico
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver por que apagar o arquivo não basta, achar o segredo no histórico e a ordem certa da remediação
#  EXECUTE   bash modulos/10-devsecops-e-seguranca/exemplos/02-segredo-vazado.sh
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

git init -q loja && cd loja
commitar() { printf '%s\n' "$2" > "$1"; git add -- "$1"; git commit -qm "$3"; }
# O token é montado em partes para que este arquivo do curso não pareça um vazamento real.
FALSO="glpat-""EXEMPLOdoCURSO1234567"
commitar README.md "# Loja" "docs: readme"
commitar config.env "API_URL=https://api.exemplo.dev
GITLAB_TOKEN=$FALSO" "feat: configuração"
git rm -q config.env && git commit -qm "remove config.env (ops!)"
passo "O arquivo sumiu do diretório…"
ls
passo "…mas continua no histórico: qualquer clone tem o token"
git log --oneline
git log -p --all -G 'glpat-' --format='commit %h: %s' | grep -E '^commit|glpat-' | sed -E 's/(glpat-.{4}).*/\1… (truncado)/'
passo "Varredura do histórico pelos prefixos de token do GitLab"
mapfile -t commits < <(git rev-list --all)
git grep -nE '(glpat|gldt|glrt|glcbt|glptt|glft)-[A-Za-z0-9_-]{20}' "${commits[@]}" 2>/dev/null \
    | sed -E 's/(gl[a-z]+-.{4})[A-Za-z0-9_-]+/\1…/' | sort -u
passo "Remediação — NESTA ordem"
cat <<'EOF'
 1. Revogar o token (User settings → Access tokens) — antes de qualquer outra coisa
 2. Criar um novo e guardar como variável de CI/CD Masked + Protected (ou cofre/OIDC)
 3. Limpar o histórico:  git filter-repo --invert-paths --path config.env
 4. Force push nas branches afetadas e pedir a todos que reclonem
 5. Ligar a Secret push protection (Ultimate) ou um hook local (gitleaks) para não repetir
EOF
