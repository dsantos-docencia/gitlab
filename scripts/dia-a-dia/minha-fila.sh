#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/dia-a-dia/minha-fila.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  A sua fila do dia, num lugar só: MRs que pedem a SUA revisão, os seus MRs
#  abertos e os issues atribuídos a você.
#
#  USO
#    minha-fila.sh [-R GRUPO/PROJETO | -g GRUPO]
#      sem opção: o projeto do diretório atual (como o glab)
# ============================================================================
set -euo pipefail

escopo=()
case "${1:-}" in
    -R|-g) [[ -n "${2:-}" ]] || { echo "uso: $0 [-R GRUPO/PROJETO | -g GRUPO]" >&2; exit 2; }
           escopo=("$1" "$2") ;;
    -h|--help) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
    '') ;;
    *) echo "uso: $0 [-R GRUPO/PROJETO | -g GRUPO]" >&2; exit 2 ;;
esac

secao() {   # secao TÍTULO FILTRO-JQ comando...
    local titulo="$1" filtro="$2"; shift 2
    local json; json="$("$@" "${escopo[@]}" --output json)"
    printf '\n%s (%s)\n' "$titulo" "$(jq length <<<"$json")"
    jq -r "$filtro" <<<"$json"
}
MR='.[] | "  \(.references.full)  \(.title)  · \(.author.username), \(.created_at[:10])\(if .draft then "  [rascunho]" else "" end)"'
IS='.[] | "  #\(.iid)  \(.title)  [\(.labels | join(", "))]\(if .milestone then "  → \(.milestone.title)" else "" end)"'

echo "Fila de $(glab api user | jq -r .username)"
secao "👀 Revisões pedidas a você" "$MR" glab mr list --reviewer=@me
secao "🚧 Seus MRs abertos"        "$MR" glab mr list --author=@me
secao "📌 Issues atribuídos a você" "$IS" glab issue list --assignee=@me
