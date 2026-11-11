#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 03 · O ciclo de vida de um issue
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  criar labels, abrir um issue com quick actions, comentar e fechar — no simulado ou no seu laboratório
#  EXECUTE   bash modulos/03-issues-labels-e-boards/exemplos/01-ciclo-de-um-issue.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/03-issues-labels-e-boards/exemplos/01-ciclo-de-um-issue.sh   (GitLab de verdade)
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

passo "Labels (a cor precisa de #)"
mostra glab label create --name bug --color "#d73a4a" --description "Algo não funciona" -R "$LAB_PROJETO"
mostra glab label create --name "prioridade::alta" --color "#d93f0b" --description "Resolver nesta semana" -R "$LAB_PROJETO"

passo "Issue com descrição + quick actions no final"
descricao=$'**Passos:** Perfil → Foto → enviar 6 MB → Salvar\n**Esperado:** aviso "máx. 5 MB" · **Obtido:** erro 500\n\n/label ~bug ~"prioridade::alta"\n/estimate 2h'
url="$(glab issue create -R "$LAB_PROJETO" -t "Erro 500 ao salvar perfil com foto grande" -d "$descricao" --yes)"
echo "criado: $url"; numero="${url##*/}"

passo "Comentário que também age (quick action no comentário)"
mostra glab issue note "$numero" -R "$LAB_PROJETO" -m $'Reproduzido.\n/assign @me'
mostra glab issue close "$numero" -R "$LAB_PROJETO"
