#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/auditoria/revisar-acessos.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Quem tem acesso a um projeto ou grupo, por papel (incluindo quem herda do
#  grupo), com alertas: Maintainers+ demais, contas bloqueadas e acesso sem
#  data de expiração para papéis altos.
#
#  USO
#    revisar-acessos.sh GRUPO/PROJETO | --grupo GRUPO  [--max-maintainers N] [--json]
# ============================================================================
set -euo pipefail

alvo='' tipo=projects max=1 json=0
while (( $# )); do
    case "$1" in
        --grupo)           tipo=groups; alvo="${2:?--grupo precisa de um caminho}"; shift ;;
        --max-maintainers) max="${2:?}"; shift ;;
        --json)            json=1 ;;
        -h|--help)         sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)                echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)                 alvo="$1" ;;
    esac
    shift
done
[[ -n "$alvo" && "$max" =~ ^[0-9]+$ ]] || { echo "uso: $0 GRUPO/PROJETO | --grupo GRUPO [--max-maintainers N] [--json]" >&2; exit 2; }
[[ "$tipo" == groups || "$alvo" == */* ]] || { echo "erro: projeto no formato GRUPO/PROJETO (ou use --grupo)" >&2; exit 2; }

enc="$(jq -rn --arg v "$alvo" '$v | @uri')"
# members/all = diretos + herdados dos grupos acima (é o acesso que vale).
membros="$(glab api --paginate "$tipo/$enc/members/all?per_page=100")"

relatorio="$(jq --argjson max "$max" '
  def papel: {"5": "Minimal", "10": "Guest", "15": "Planner", "20": "Reporter", "30": "Developer", "40": "Maintainer", "50": "Owner"}[tostring] // "?";
  {
    por_papel: (group_by(.access_level) | reverse | map({papel: (.[0].access_level | papel), nivel: .[0].access_level, pessoas: (map(.username) | sort)})),
    alertas: (
      ([.[] | select(.access_level >= 40)] as $altos
       | if ($altos | length) > $max then ["\($altos | length) pessoas com Maintainer ou acima (máx. \($max)): \($altos | map(.username) | sort | join(", "))"] else [] end)
      + [.[] | select(.state != "active") | "conta \(.state): \(.username) ainda tem acesso"]
      + [.[] | select(.access_level >= 40 and (.expires_at == null) and .access_level < 50) | "\(.username) é \(.access_level | papel) sem data de expiração"]
    )
  }' <<<"$membros")"

if (( json )); then
    jq --arg alvo "$alvo" '{alvo: $alvo} + .' <<<"$relatorio"
else
    echo "Acessos de $alvo"
    jq -r '.por_papel[] | "  \(.papel | . + "            " | .[:11]) \(.pessoas | join(", "))"' <<<"$relatorio"
    jq -r 'if (.alertas | length) == 0 then "nenhum alerta" else (.alertas[] | "  ⚠ \(.)") end' <<<"$relatorio"
fi
[[ "$(jq '.alertas | length' <<<"$relatorio")" == 0 ]]
