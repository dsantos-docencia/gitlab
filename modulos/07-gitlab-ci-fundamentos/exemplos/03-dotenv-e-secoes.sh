#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 07 · Dotenv entre jobs e seções no log
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  emular dois jobs: um produz variáveis via dotenv, o outro as recebe; e ver as seções recolhíveis
#  EXECUTE   bash modulos/07-gitlab-ci-fundamentos/exemplos/03-dotenv-e-secoes.sh
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

secao_inicio() { echo -e "\e[0Ksection_start:$(date +%s):$1[collapsed=true]\r\e[0K$2"; }
secao_fim()    { echo -e "\e[0Ksection_end:$(date +%s):$1\r\e[0K"; }

passo "Job 'versao' (stage build) — escreve build.env (artifacts:reports:dotenv)"
printf '1.4.0-rc.1\n' > VERSION
secao_inicio versao "Calculando a versão"
v="$(cat VERSION)"; pre=false; [[ "$v" == *-* ]] && pre=true
printf 'VERSAO=%s\nPRERELEASE=%s\n' "$v" "$pre" > build.env
secao_fim versao
cat build.env

passo "Job 'publicar' (stage deploy) — o runner já carregou o dotenv como variáveis"
( set -a; # shellcheck source=/dev/null
  source build.env; set +a
  echo "Publicando $VERSAO (pré-lançamento: $PRERELEASE)" )

passo "Como as seções aparecem no log cru (no GitLab viram blocos recolhíveis)"
secao_inicio teste "Rodando os testes" | cat -v
