#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 01 · Configuração SSH para o GitLab
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  montar um ~/.ssh/config didático (numa pasta temporária), incluindo a porta 443
#  EXECUTE   bash modulos/01-conta-seguranca-e-autenticacao/exemplos/01-config-ssh.sh
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

mkdir -p .ssh && chmod 700 .ssh
passo "1. Par de chaves (se o ssh-keygen existir)"
if command -v ssh-keygen >/dev/null; then
    mostra ssh-keygen -q -t ed25519 -N '' -C 'ana@exemplo.dev' -f .ssh/id_ed25519_gitlab
    echo "pública (esta vai para o GitLab):"; cat .ssh/id_ed25519_gitlab.pub
else
    echo "(ssh-keygen não instalado aqui — no seu computador o comando é o de cima)"
fi

passo "2. O config"
cat > .ssh/config <<CFG
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile $LAB/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes

Host gitlab-443
    HostName altssh.gitlab.com
    Port 443
    User git
    IdentityFile $LAB/.ssh/id_ed25519_gitlab
CFG
chmod 600 .ssh/config; cat .ssh/config

passo "3. O que o ssh usaria (ssh -G não conecta, só resolve)"
if command -v ssh >/dev/null; then ssh -G -F .ssh/config gitlab-443 | grep -E '^(hostname|port|user) '
else echo "(cliente ssh não instalado aqui)"; fi

passo "4. URLs equivalentes"
printf '%s\n' "HTTPS ......... https://gitlab.com/aluno/laboratorio.git" \
              "SSH ........... git@gitlab.com:aluno/laboratorio.git" \
              "SSH porta 443 . git@gitlab-443:aluno/laboratorio.git"
