#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 09 · Empacotar e publicar no Package Registry
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  gerar um pacote com checksum e montar a URL e o comando de publicação do registry genérico
#  EXECUTE   bash modulos/09-releases-pacotes-e-pages/exemplos/02-pacote-generico.sh
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

NOME=loja VERSAO=1.2.0
passo "Compilando e empacotando"
mkdir -p dist && printf 'loja %s\n' "$VERSAO" > dist/loja.txt
tar -czf "dist/$NOME-$VERSAO.tar.gz" -C dist loja.txt
(cd dist && sha256sum "$NOME-$VERSAO.tar.gz" | tee "$NOME-$VERSAO.tar.gz.sha256")
passo "Para onde vai (API do registry genérico)"
API=https://gitlab.com/api/v4
URL="$API/projects/$(enc "$LAB_PROJETO")/packages/generic/$NOME/$VERSAO/$NOME-$VERSAO.tar.gz"
echo "$URL"
passo "O comando — no pipeline o CI_JOB_TOKEN autentica; aqui só mostramos"
cat <<EOF
curl --fail-with-body --header "JOB-TOKEN: \$CI_JOB_TOKEN" \\
     --upload-file dist/$NOME-$VERSAO.tar.gz \\
     "$URL"
EOF
echo
echo "Nome do pacote: letras, números, . _ - ; versão: SemVer. O .sha256 permite conferir o download."
