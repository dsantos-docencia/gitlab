#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 00 · Markdown e referências do GitLab
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  gerar uma descrição de issue com GLFM e destacar cada tipo de referência que o GitLab transforma em link
#  EXECUTE   bash modulos/00-boas-vindas-e-fundamentos/exemplos/02-markdown-e-referencias.sh
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

cat > descricao.md <<'MD'
[[_TOC_]]

## Contexto
> [!important]
> Bloqueia a entrega %v1.1 — ver épico &3.

## O que fazer
- [x] reproduzir o erro (#12)
- [ ] corrigir no MR !7
- [~] testar no Internet Explorer

## Quem acompanha
@bia-dev revisa; o time @escola-dev/backend é avisado. Label ~"prioridade::alta".
Commit suspeito: a1b2c3d · outro projeto: escola-dev/loja#40
MD
passo "A descrição"
cat descricao.md

passo "Referências que o GitLab vai transformar em link"
grep -oE '(^|[ (])(#[0-9]+|![0-9]+|&[0-9]+|%[A-Za-z0-9.]+|~"[^"]+"|~[A-Za-z0-9:]+|@[A-Za-z0-9/_-]+|[a-z0-9-]+/[a-z0-9-]+#[0-9]+)' descricao.md |
    sed 's/^[ (]//' | while read -r ref; do
        case "$ref" in
            */*\#*) tipo='issue de outro projeto' ;;
            \#*) tipo='issue' ;;   \!*) tipo='merge request' ;;  \&*) tipo='épico' ;;
            %*) tipo='milestone' ;; ~*) tipo='label' ;;           @*/*) tipo='grupo (notifica todos!)' ;;
            @*) tipo='pessoa' ;;
        esac
        printf '  %-22s → %s\n' "$ref" "$tipo"
    done
