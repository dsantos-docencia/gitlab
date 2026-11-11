#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/ci/limpar-pipelines.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Apaga pipelines antigos (e, com eles, logs e artefatos) para liberar
#  armazenamento — o plano Free tem 10 GiB por projeto. Simula por padrão.
#
#  USO
#    limpar-pipelines.sh GRUPO/PROJETO [--dias N | --antes-de AAAA-MM-DD]
#                        [--manter-padrao] [--aplicar]
#      --dias N          mais antigos que N dias (padrão: 90)
#      --manter-padrao   nunca apaga pipelines da branch padrão
#      --aplicar         apaga de verdade (sem isto: só lista)
# ============================================================================
set -euo pipefail

projeto='' dias=90 antes='' manter=0 aplicar=0
while (( $# )); do
    case "$1" in
        --dias)          dias="${2:?}"; shift ;;
        --antes-de)      antes="${2:?}"; shift ;;
        --manter-padrao) manter=1 ;;
        --aplicar)       aplicar=1 ;;
        -h|--help)       sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)              echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)               projeto="$1" ;;
    esac
    shift
done
[[ "$projeto" == */* ]] || { echo "uso: $0 GRUPO/PROJETO [--dias N | --antes-de AAAA-MM-DD] [--aplicar]" >&2; exit 2; }
[[ "$dias" =~ ^[0-9]+$ ]] || { echo "erro: --dias precisa ser um número" >&2; exit 2; }
if [[ -z "$antes" ]]; then antes="$(date -u -d "-$dias days" +%F)"; fi
[[ "$antes" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "erro: data no formato AAAA-MM-DD" >&2; exit 2; }

enc="$(jq -rn --arg v "$projeto" '$v | @uri')"
padrao="$(glab api "projects/$enc" | jq -r .default_branch)"

# O filtro updated_before já vem da API; o jq repete a checagem (defesa em
# profundidade) e tira pipelines ainda rodando, que não devem ser apagados.
lista="$(glab api --paginate "projects/$enc/pipelines?updated_before=${antes}T00:00:00Z&per_page=100" |
    jq -r --arg antes "$antes" --arg padrao "$padrao" --argjson manter "$manter" '
      .[] | select(.created_at[:10] < $antes)
          | select(.status | IN("running", "pending", "created") | not)
          | select(($manter == 1 and .ref == $padrao) | not)
          | [.id, .ref, .status, .created_at[:10]] | @tsv')"

n=0
while IFS=$'\t' read -r id ref status quando; do
    [[ -n "$id" ]] || continue
    if (( aplicar )); then
        glab api -X DELETE "projects/$enc/pipelines/$id" >/dev/null
        echo "  🗑 #$id  $ref  $status  $quando"
    else
        echo "  (simulação) apagaria #$id  $ref  $status  $quando"
    fi
    (( ++n ))
done <<<"$lista"
echo "$n pipelines anteriores a $antes$([[ $aplicar == 1 ]] && echo " apagados" || echo " — use --aplicar para apagar")"
