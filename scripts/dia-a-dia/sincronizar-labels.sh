#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/dia-a-dia/sincronizar-labels.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Aplica um conjunto padrão de labels (inclusive com escopo, prioridade::alta)
#  a um projeto: cria as que faltam e lista as que sobram. Remover as extras
#  só com --remover-extras --aplicar (apagar label tira ela de todos os issues).
#
#  USO
#    sincronizar-labels.sh GRUPO/PROJETO [--arquivo ARQ.tsv] [--remover-extras [--aplicar]]
#      ARQ.tsv: nome<TAB>cor<TAB>descrição (uma por linha; # comenta)
# ============================================================================
set -euo pipefail

projeto='' arquivo='' remover=0 aplicar=0
while (( $# )); do
    case "$1" in
        --arquivo)        arquivo="${2:?--arquivo precisa de um caminho}"; shift ;;
        --remover-extras) remover=1 ;;
        --aplicar)        aplicar=1 ;;
        -h|--help)        sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)               echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)                projeto="$1" ;;
    esac
    shift
done
[[ "$projeto" == */* ]] || { echo "uso: $0 GRUPO/PROJETO [--arquivo ARQ.tsv] [--remover-extras [--aplicar]]" >&2; exit 2; }

padrao=$'bug\t#d73a4a\tAlgo não funciona
melhoria\t#a2eeef\tNova funcionalidade ou ajuste
documentação\t#0075ca\tDocumentação
precisa-triagem\t#fbca04\tAinda não avaliado
prioridade::alta\t#b60205\tResolver primeiro
prioridade::média\t#d93f0b\tPróximo ciclo
prioridade::baixa\t#0e8a16\tQuando der'
if [[ -n "$arquivo" ]]; then
    [[ -f "$arquivo" ]] || { echo "erro: não encontrado: $arquivo" >&2; exit 2; }
    padrao="$(grep -vE '^\s*(#|$)' "$arquivo")"
fi

enc="$(jq -rn --arg v "$projeto" '$v | @uri')"
existentes="$(glab api --paginate "projects/$enc/labels?per_page=100" | jq -r '.[].name')"

criadas=0
while IFS=$'\t' read -r nome cor desc; do
    if grep -qxF -- "$nome" <<<"$existentes"; then continue; fi
    glab api -X POST "projects/$enc/labels" -f name="$nome" -f color="$cor" -f description="$desc" >/dev/null
    echo "  ✔ criada  $nome"; (( ++criadas ))
done <<<"$padrao"

extras="$(comm -23 <(sort <<<"$existentes") <(cut -f1 <<<"$padrao" | sort))"
removidas=0
while IFS= read -r nome; do
    [[ -n "$nome" ]] || continue
    if (( remover && aplicar )); then
        glab api -X DELETE "projects/$enc/labels/$(jq -rn --arg v "$nome" '$v | @uri')" >/dev/null
        echo "  🗑 removida $nome"; (( ++removidas ))
    elif (( remover )); then
        echo "  (simulação) removeria $nome — use --aplicar"
    else
        echo "  • extra   $nome"
    fi
done <<<"$extras"
echo "$criadas criadas, $removidas removidas"
