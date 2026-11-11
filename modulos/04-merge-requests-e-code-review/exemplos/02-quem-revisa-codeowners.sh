#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 04 · Quem revisa? CODEOWNERS com seções
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  simular a regra do GitLab: a última que casa vence DENTRO da seção; as seções se somam
#  EXECUTE   bash modulos/04-merge-requests-e-code-review/exemplos/02-quem-revisa-codeowners.sh
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

cat > CODEOWNERS <<'TXT'
* @aluno

[Frontend] @bia-dev
*.js
*.css

[Documentação]
/docs/ @escola-dev/docs

^[Opcional]
*.md @caio-qa
TXT
casa() {   # versão simplificada do casamento de padrões
    local p="$1" c="$2"
    # shellcheck disable=SC2053
    if [[ "$p" == */ ]]; then [[ "/$c" == "$p"* ]]
    elif [[ "$p" == /* ]]; then [[ "/$c" == $p ]]
    else [[ "${c##*/}" == $p || "$c" == $p ]]; fi
}
donos() {
    local arq="$1" secao='(sem seção)' padrao_secao='' l p resto
    declare -A por_secao=()
    while IFS= read -r l; do
        [[ -z "$l" || "$l" == \#* ]] && continue
        if [[ "$l" =~ ^\^?\[([^]]+)\](.*)$ ]]; then
            secao="${BASH_REMATCH[1]}"; [[ "$l" == ^* ]] && secao+=" (opcional)"
            padrao_secao="$(xargs <<<"${BASH_REMATCH[2]}")"; continue
        fi
        read -r p resto <<<"$l"
        casa "$p" "$arq" && por_secao["$secao"]="${resto:-$padrao_secao}"
    done < CODEOWNERS
    for s in "${!por_secao[@]}"; do printf '[%s] %s; ' "$s" "${por_secao[$s]}"; done
}
passo "Quem é pedido como revisor"
for f in README.md src/app.js docs/guia.md docs/exemplo.js; do
    printf '%-18s → %s\n' "$f" "$(donos "$f")"
done
echo
echo "docs/exemplo.js precisa de donos de TRÊS seções: as seções se somam."
