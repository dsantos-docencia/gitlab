#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 04.03 — MR criado pelo git push · SOLUÇÃO COMENTADA
set -euo pipefail

issue="${1:-}"
[[ "$issue" =~ ^[0-9]+$ ]] || { echo "uso: $0 <número-do-issue>" >&2; exit 2; }
cd app
branch="$(git branch --show-current)"
titulo="$(git log -1 --format=%s)"
# Cada -o vira uma push option; aspas mantêm títulos com espaço inteiros.
git push -q -u origin "$branch" \
    -o merge_request.create \
    -o merge_request.target=main \
    -o "merge_request.title=$titulo" \
    -o "merge_request.description=Closes #$issue" \
    -o merge_request.remove_source_branch
