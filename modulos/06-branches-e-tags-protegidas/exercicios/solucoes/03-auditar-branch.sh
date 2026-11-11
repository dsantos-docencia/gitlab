#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 06.03 — Auditoria de uma branch protegida · SOLUÇÃO COMENTADA
set -euo pipefail

projeto="${1:-}" branch="${2:-main}"
[[ "$projeto" == */* ]] || { echo "uso: $0 <grupo/projeto> [branch]" >&2; exit 2; }
P="$(jq -rn --arg v "$projeto" '$v | @uri')" B="$(jq -rn --arg v "$branch" '$v | @uri')"
if ! json="$(glab api "projects/$P/protected_branches/$B" 2>/dev/null)"; then
    echo "✘ branch não protegida"; exit 1
fi
falhou=0
checar() {   # checar "descrição" 'filtro jq'
    if jq -e "$2" >/dev/null <<<"$json"; then echo "✔ $1"; else echo "✘ $1"; falhou=1; fi
}
checar "push direto bloqueado" '.push_access_levels | length > 0 and all(.access_level == 0)'
checar "merge restrito"        '(.merge_access_levels | map(.access_level) | min) >= 30'
checar "force push bloqueado"  '.allow_force_push == false'
exit "$falhou"
