#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 02.03 — Membros por papel · SOLUÇÃO COMENTADA
set -euo pipefail

projeto="${1:-}"
[[ "$projeto" == */* ]] || { echo "uso: $0 <grupo/projeto>" >&2; exit 2; }
caminho="$(jq -rn --arg v "$projeto" '$v | @uri')"
membros="$(glab api --paginate "projects/$caminho/members/all?per_page=100")"

# Um dicionário no próprio jq traduz o número para o nome do papel.
jq -r '{"10":"Guest","15":"Planner","20":"Reporter","30":"Developer","40":"Maintainer","50":"Owner"} as $nome
       | group_by(.access_level) | reverse[]
       | "\($nome[(.[0].access_level | tostring)]): \(map(.username) | sort | join(", "))"' <<<"$membros"

fortes="$(jq '[.[] | select(.access_level >= 40)] | length' <<<"$membros")"
(( fortes > 1 )) && echo "⚠ $fortes pessoas podem alterar branches protegidas"
exit 0
