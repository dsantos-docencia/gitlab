#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 04 · Revisão pelo terminal
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  encontrar MRs à sua espera, ler um MR e registrar comentário e aprovação
#  EXECUTE   bash modulos/04-merge-requests-e-code-review/exemplos/03-revisao-pelo-terminal.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/04-merge-requests-e-code-review/exemplos/03-revisao-pelo-terminal.sh   (GitLab de verdade)
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

passo "MRs aguardando a minha revisão"
echo "\$ glab mr list -R $LAB_PROJETO --reviewer=@me --output json | jq …"
glab mr list -R "$LAB_PROJETO" --reviewer=@me --output json |
    jq -r '.[] | "!\(.iid) \(.title) — @\(.author.username) [\(.detailed_merge_status)]"'
passo "Lendo o !7"
glab mr view 7 -R "$LAB_PROJETO" --output json | jq -r '"\(.title)\n\(.description)\n(\(.source_branch) → \(.target_branch))"'
passo "Comentário (com quick action) e aprovação"
mostra glab mr note 7 -R "$LAB_PROJETO" -m $'nit: nome da função.\nBloqueante: tratar e-mail vazio.\n/label ~"status::ajustes"'
mostra glab mr approve 7 -R "$LAB_PROJETO"
