#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 06.01 — Proteger a main (idempotente) · SOLUÇÃO COMENTADA
set -euo pipefail

projeto="${1:-}"
[[ "$projeto" == */* ]] || { echo "uso: $0 <grupo/projeto>" >&2; exit 2; }
P="$(jq -rn --arg v "$projeto" '$v | @uri')"
# A API não altera níveis de acesso de uma branch já protegida:
# desprotege (se preciso) e protege de novo — o resultado é sempre o mesmo.
if glab api "projects/$P/protected_branches/main" >/dev/null 2>&1; then
    glab api -X DELETE "projects/$P/protected_branches/main" >/dev/null
fi
glab api -X POST "projects/$P/protected_branches" -f name=main \
    -F push_access_level=0 -F merge_access_level=30 -F allow_force_push=false >/dev/null
echo "main protegida em $projeto"
