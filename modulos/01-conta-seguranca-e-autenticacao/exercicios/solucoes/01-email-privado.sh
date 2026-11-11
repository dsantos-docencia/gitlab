#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 01.01 — E-mail privado nos commits · SOLUÇÃO COMENTADA
set -euo pipefail

id="${1:-}" usuario="${2:-}"
[[ -n "$id" && -n "$usuario" ]] || { echo "uso: $0 <id> <usuario>   (glab api user | jq .id)" >&2; exit 2; }
[[ "$id" =~ ^[0-9]+$ ]] || { echo "erro: o ID precisa ser numérico (recebi '$id')" >&2; exit 1; }
git init -q -b main projeto
git -C projeto config --local user.name "$usuario"
# GitLab usa HÍFEN entre ID e usuário (o GitHub usa +).
git -C projeto config --local user.email "$id-$usuario@users.noreply.gitlab.com"
