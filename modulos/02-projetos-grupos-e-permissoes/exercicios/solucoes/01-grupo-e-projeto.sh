#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 02.01 — Criar grupo e projeto · SOLUÇÃO COMENTADA
set -euo pipefail

nome="${1:-}" caminho="${2:-}" projeto="${3:-}"
if [[ -z "$nome" || -z "$projeto" || ! "$caminho" =~ ^[a-z0-9][a-z0-9._-]*$ ]]; then
    echo "uso: $0 <nome do grupo> <caminho-do-grupo> <projeto>   (caminho: a-z 0-9 . _ -)" >&2
    exit 2
fi
# Nome é para humanos (pode ter espaço/acento); caminho é o que vai na URL.
glab api -X POST groups -f name="$nome" -f path="$caminho" -f visibility=private
glab repo create "$projeto" --group "$caminho" --private --defaultBranch main
