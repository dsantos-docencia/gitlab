#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 11 · Espelhando um repositório
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  espelhar à mão com git --mirror e configurar um push mirror permanente pela API
#  EXECUTE   bash modulos/11-api-automacao-e-administracao/exemplos/03-espelhamento.sh
#            GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab bash modulos/11-api-automacao-e-administracao/exemplos/03-espelhamento.sh   (GitLab de verdade)
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

commitar() { printf '%s\n' "$2" > "$1"; git add -- "$1"; git commit -qm "$3"; }
passo "Origem com branches e tag"
git init -q origem && (cd origem && commitar README.md "# Loja" "docs: readme" && git tag v1.0.0 &&
    git switch -qc feature/csv && commitar csv.txt "csv" "feat: csv" && git switch -q main)
git init -q --bare destino.git
passo "Espelho manual: --mirror copia TODAS as refs (branches, tags, notes)"
mostra git clone -q --mirror origem espelho.git
mostra git -C espelho.git push -q --mirror ../destino.git
passo "Origem e destino têm as mesmas refs?"
diff <(git -C origem for-each-ref --format='%(refname) %(objectname)') \
     <(git -C destino.git for-each-ref --format='%(refname) %(objectname)') && echo "  ✔ idênticos"
git -C destino.git for-each-ref --format='  %(refname)'
passo "Push mirror permanente (o GitLab empurra a cada mudança)"
mostra glab api -X POST "projects/$(enc "$LAB_PROJETO")/remote_mirrors" \
    -f 'url=https://usuario:TOKEN@gitlab.exemplo.dev/espelho/loja.git' \
    -F enabled=true -F only_protected_branches=true | jq -r '"  espelho \(.id): \(.url) (só protegidas: \(.only_protected_branches))"'
