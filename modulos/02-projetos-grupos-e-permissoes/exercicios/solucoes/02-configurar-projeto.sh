#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 02.02 — Regras de merge pela API · SOLUÇÃO COMENTADA
set -euo pipefail

projeto="${1:-}"
[[ "$projeto" == */* ]] || { echo "uso: $0 <grupo/projeto>" >&2; exit 2; }
# @uri do jq codifica tudo que não pode ir cru numa URL: "/" vira "%2F".
caminho="$(jq -rn --arg v "$projeto" '$v | @uri')"
# -f manda texto; -F manda valor tipado (true/false viram booleanos de verdade).
glab api -X PUT "projects/$caminho" \
    -f merge_method=ff -f squash_option=default_on \
    -F only_allow_merge_if_pipeline_succeeds=true \
    -F only_allow_merge_if_all_discussions_are_resolved=true \
    -F remove_source_branch_after_merge=true
