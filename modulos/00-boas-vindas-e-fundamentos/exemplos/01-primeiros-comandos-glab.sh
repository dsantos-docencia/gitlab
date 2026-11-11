#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 00 · Primeiros comandos do glab
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver o glab em ação: autenticação, projeto, issues e o filtro com jq
#  EXECUTE   bash modulos/00-boas-vindas-e-fundamentos/exemplos/01-primeiros-comandos-glab.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/00-boas-vindas-e-fundamentos/exemplos/01-primeiros-comandos-glab.sh   (GitLab de verdade)
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

passo "Qual glab está respondendo?"
mostra glab version
[[ "${GLAB_REAL:-0}" != 1 ]] && echo "(é o SIMULADOR do curso: $(command -v glab))"

passo "Quem sou eu para o GitLab?"
mostra glab auth status

passo "O projeto de laboratório (a API quer o caminho codificado: aluno%2Flaboratorio)"
echo "\$ glab api projects/$(enc "$LAB_PROJETO") | jq …"
glab api "projects/$(enc "$LAB_PROJETO")" |
    jq -r '"\(.path_with_namespace) [\(.visibility)] — \(.description)"'

passo "Issues abertas: JSON + jq (o glab não tem --jq)"
echo "\$ glab issue list -R $LAB_PROJETO --output json | jq …"
glab issue list -R "$LAB_PROJETO" --output json | jq -r '.[] | "#\(.iid)  \(.title)  ~\(.labels | join(" ~"))"'

if [[ "${GLAB_REAL:-0}" != 1 ]]; then
    passo "O que o simulador registrou (é isso que o corretor lê)"
    chamadas_glab
fi
