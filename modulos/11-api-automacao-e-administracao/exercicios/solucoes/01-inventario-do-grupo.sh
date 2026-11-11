#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.01 — Inventário de projetos do grupo · SOLUÇÃO COMENTADA
set -euo pipefail

GRUPO="${1:-}"
[[ -n "$GRUPO" ]] || { echo "uso: $0 caminho-do-grupo" >&2; exit 2; }
ENC="$(jq -rn --arg v "$GRUPO" '$v | @uri')"     # subgrupos: escola-dev/backend → escola-dev%2Fbackend

echo "caminho,visibilidade,ultima_atividade"
# --paginate segue o x-next-page até a última página (sem ele: só 20 itens).
glab api --paginate "groups/$ENC/projects?include_subgroups=true&per_page=100" |
    jq -r 'map(select(.archived | not)) | sort_by(.path_with_namespace)[]
           | [.path_with_namespace, .visibility, (.last_activity_at | .[:10])] | join(",")'
