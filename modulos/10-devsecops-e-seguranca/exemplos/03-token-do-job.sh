#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 10 · Quem pode usar o CI_JOB_TOKEN contra este projeto?
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  auditar o escopo do token do job e a allowlist pela API
#  EXECUTE   bash modulos/10-devsecops-e-seguranca/exemplos/03-token-do-job.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/10-devsecops-e-seguranca/exemplos/03-token-do-job.sh   (GitLab de verdade)
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

# --- glab: simulado por padrão; o de verdade com GLAB_REAL=1 ----------------
# Simulado = offline, sem conta, nada é criado; cada chamada fica registrada.
if [[ "${GLAB_REAL:-0}" == 1 ]]; then
    : "${LAB_PROJETO:?defina LAB_PROJETO=seu-usuario/lab-gitlab (veja laboratorio/)}"
    glab auth status >/dev/null 2>&1 || { echo "rode 'glab auth login' antes" >&2; exit 1; }
else
    # shellcheck source=/dev/null
    source "$CURSO/ferramentas/lib/glab-simulado.sh"
    LAB_PROJETO='aluno/laboratorio'
fi
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

ENC="$(enc "$LAB_PROJETO")"
passo "Escopo do token do job"
echo "\$ glab api projects/$ENC/job_token_scope"
glab api "projects/$ENC/job_token_scope" | jq -r '
  "  entrada restrita à allowlist (inbound_enabled): \(.inbound_enabled)"'
passo "Allowlist: projetos cujos jobs podem acessar este com o próprio token"
echo "\$ glab api projects/$ENC/job_token_scope/allowlist"
glab api "projects/$ENC/job_token_scope/allowlist" | jq -r '.[] | "  \(.id)  \(.path_with_namespace)"'
echo
echo "inbound_enabled=false seria o alerta: qualquer projeto da instância com acesso poderia usar o token."
