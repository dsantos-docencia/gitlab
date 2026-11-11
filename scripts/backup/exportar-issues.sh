#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/backup/exportar-issues.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Exporta todos os issues (abertos e fechados) para JSON + um índice em
#  Markdown. Issues, MRs e wiki NÃO vêm no git clone — sem exportar, eles só
#  existem no servidor. (Para tudo de uma vez: Settings → General → Export.)
#
#  USO
#    exportar-issues.sh GRUPO/PROJETO [--destino DIR]   (padrão: backup-issues-AAAA-MM-DD)
# ============================================================================
set -euo pipefail

projeto='' destino="backup-issues-$(date +%F)"
while (( $# )); do
    case "$1" in
        --destino) destino="${2:?--destino precisa de uma pasta}"; shift ;;
        -h|--help) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)        echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)         projeto="$1" ;;
    esac
    shift
done
[[ "$projeto" == */* ]] || { echo "uso: $0 GRUPO/PROJETO [--destino DIR]" >&2; exit 2; }

enc="$(jq -rn --arg v "$projeto" '$v | @uri')"
mkdir -p -- "$destino"
# --paginate devolve várias listas JSON seguidas; jq -s add junta numa só.
glab api --paginate "projects/$enc/issues?state=all&per_page=100&order_by=created_at&sort=asc" |
    jq -s 'add // [] | sort_by(.iid)' > "$destino/issues.json"

{
    echo "# Issues de $projeto"
    echo
    echo "Exportado em $(date -u +'%F %T') UTC · $(jq length "$destino/issues.json") issues"
    echo
    echo "| # | Título | Estado | Labels | Responsáveis | Criado |"
    echo "|---|---|---|---|---|---|"
    jq -r '.[] | "| \(.iid) | \(.title | gsub("\\|"; "\\|")) | \(.state) | \(.labels | join(", ")) | \([.assignees[].username] | join(", ")) | \(.created_at[:10]) |"' "$destino/issues.json"
} > "$destino/INDICE.md"
echo "$(jq length "$destino/issues.json") issues exportados para $destino/"
