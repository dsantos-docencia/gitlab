#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 01 · Reconhecendo tokens do GitLab
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  identificar o tipo de token pelo prefixo e procurar tokens esquecidos num projeto, sem nunca exibi-los
#  EXECUTE   bash modulos/01-conta-seguranca-e-autenticacao/exemplos/02-reconhecer-tokens.sh
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

# Tokens FALSOS, só para estudo.
falsos=(glpat-FAKEaaaaaaaaaaaaaaaaaaaa gldt-FAKEbbbbbbbbbbbbbbbbbbbb glrt-FAKEcccccccccccccccccccc
        glcbt-FAKEdddddddddddddddddd glptt-FAKEeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee senha123)
tipo() {
    case "$1" in
        glpat-*) echo "acesso pessoal/projeto/grupo" ;;  gldt-*)  echo "deploy token" ;;
        glrt-*)  echo "runner" ;;                        glcbt-*) echo "CI job token" ;;
        glptt-*) echo "gatilho de pipeline" ;;           glft-*)  echo "feed" ;;
        *)       echo "não parece token do GitLab" ;;
    esac
}
mascarar() { printf '%s…(%d caracteres)' "${1:0:9}" "${#1}"; }

passo "Classificando (sem exibir o token inteiro)"
for t in "${falsos[@]}"; do printf '%-30s → %s\n' "$(mascarar "$t")" "$(tipo "$t")"; done

passo "Procurando tokens esquecidos"
mkdir -p projeto && cd projeto
printf 'GITLAB_TOKEN=%s\n' "${falsos[0]}" > .env
printf 'variables:\n  DEPLOY: %s\n' "${falsos[1]}" > .gitlab-ci.yml
grep -rnoE 'gl(pat|dt|rt|cbt|ptt|ft)-[A-Za-z0-9_-]{20,}' . | while IFS=: read -r arq linha achado; do
    printf '⚠ %s:%s  %s\n' "$arq" "$linha" "$(mascarar "$achado")"
done
echo "→ Achou? Revogue no GitLab ANTES de apagar o arquivo. E nunca escreva token no .gitlab-ci.yml:"
echo "  use Settings → CI/CD → Variables (masked + protected) — Módulo 10."
