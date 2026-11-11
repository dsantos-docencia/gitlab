#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 03.03 — A fila de triagem · SOLUÇÃO COMENTADA
set -euo pipefail

projeto="${1:?uso: $0 <grupo/projeto>}"
# iid = número do issue dentro do projeto (#9); id = identificador global (não use para exibir).
saida="$(glab issue list -R "$projeto" --output json --per-page 100 |
  jq -r 'map(select((.assignees | length) == 0)) | sort_by(.iid) | .[]
         | "#\(.iid) \(.title) [\(.labels | join(", "))]"')"
if [[ -n "$saida" ]]; then printf '%s\n' "$saida"; else echo "fila vazia 🎉"; fi
