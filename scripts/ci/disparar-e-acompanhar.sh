#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/ci/disparar-e-acompanhar.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Dispara um pipeline (com variáveis) e acompanha até terminar, saindo com o
#  resultado — para usar em outro script, num cron ou num deploy manual.
#
#  USO
#    disparar-e-acompanhar.sh GRUPO/PROJETO [--ref REF] [--var CHAVE=VALOR]...
#                             [--intervalo SEG] [--limite SEG]
#  SAÍDA   0 success · 1 failed/canceled/skipped · 3 passou do limite · 2 uso
# ============================================================================
set -euo pipefail

projeto='' ref=main intervalo=10 limite=1800 vars=()
while (( $# )); do
    case "$1" in
        --ref)       ref="${2:?}"; shift ;;
        --var)       [[ "${2:-}" == *=* ]] || { echo "erro: --var precisa de CHAVE=VALOR" >&2; exit 2; }
                     vars+=("$2"); shift ;;
        --intervalo) intervalo="${2:?}"; shift ;;
        --limite)    limite="${2:?}"; shift ;;
        -h|--help)   sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)          echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)           projeto="$1" ;;
    esac
    shift
done
[[ "$projeto" == */* ]] || { echo "uso: $0 GRUPO/PROJETO [--ref REF] [--var CHAVE=VALOR]..." >&2; exit 2; }
[[ "$intervalo$limite" =~ ^[0-9]+$ ]] || { echo "erro: --intervalo e --limite em segundos" >&2; exit 2; }
enc="$(jq -rn --arg v "$projeto" '$v | @uri')"

# Corpo em JSON (variáveis são uma lista de objetos): montado pelo jq, que
# cuida de aspas e acentos — nada de concatenar texto em JSON.
corpo="$(printf '%s\n' "${vars[@]}" | jq -Rn --arg ref "$ref" '
  {ref: $ref, variables: [inputs | select(length > 0) | capture("^(?<key>[^=]+)=(?<value>.*)$")]}')"
pipeline="$(glab api -X POST "projects/$enc/pipeline" -H 'Content-Type: application/json' --input - <<<"$corpo")"
id="$(jq -r .id <<<"$pipeline")"
[[ "$id" =~ ^[0-9]+$ ]] || { echo "erro: o GitLab não criou o pipeline: $pipeline" >&2; exit 1; }
echo "pipeline $id disparado em $ref: $(jq -r .web_url <<<"$pipeline")"

inicio=$SECONDS anterior=''
while :; do
    status="$(glab api "projects/$enc/pipelines/$id" | jq -r .status)"
    [[ "$status" != "$anterior" ]] && echo "  $(date +%T)  $status"
    anterior="$status"
    case "$status" in
        success)                      exit 0 ;;
        failed|canceled|skipped)      exit 1 ;;
        manual)                       echo "  aguardando ação manual no GitLab"; exit 1 ;;
    esac
    if (( SECONDS - inicio >= limite )); then
        echo "  passou de ${limite}s — o pipeline continua no GitLab" >&2; exit 3
    fi
    sleep "$intervalo"
done
