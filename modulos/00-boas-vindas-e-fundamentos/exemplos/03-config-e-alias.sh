#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 00 · Configuração e aliases do glab
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  configurar protocolo e editor do glab e criar atalhos — vendo exatamente quais comandos isso exige
#  EXECUTE   bash modulos/00-boas-vindas-e-fundamentos/exemplos/03-config-e-alias.sh
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

# No simulado, vemos os comandos e o que eles registram; no seu computador,
# eles gravam em ~/.config/glab-cli/config.yml (ou no %LOCALAPPDATA% no Windows).
passo "Protocolo do Git e editor (para todos os hosts: --global)"
mostra glab config set git_protocol ssh --global
mostra glab config set editor "code --wait" --global

passo "Uma instância própria? Configuração por host"
mostra glab config set api_protocol https --host gitlab.empresa.local

passo "Aliases: seus próprios comandos"
mostra glab alias set minhas 'issue list --assignee=@me'
mostra glab alias set revisar 'mr list --reviewer=@me'

passo "Registro"
chamadas_glab
