#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 06.02 — Proteger as tags de versão · SOLUÇÃO COMENTADA
set -euo pipefail

projeto="${1:-}" padrao="${2:-v*}"
[[ "$projeto" == */* ]] || { echo "uso: $0 <grupo/projeto> [padrão]" >&2; exit 2; }
enc() { jq -rn --arg v "$1" '$v | @uri'; }
P="$(enc "$projeto")" T="$(enc "$padrao")"      # v* → v%2A
if glab api "projects/$P/protected_tags/$T" >/dev/null 2>&1; then
    glab api -X DELETE "projects/$P/protected_tags/$T" >/dev/null
fi
# No corpo (-f), o nome vai cru: só a URL precisa de codificação.
glab api -X POST "projects/$P/protected_tags" -f name="$padrao" -F create_access_level=40 >/dev/null
echo "tags $padrao protegidas em $projeto"
