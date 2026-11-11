#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 01.03 — Classificador de tokens do GitLab · SOLUÇÃO COMENTADA
set -euo pipefail

token="${1:-}"
[[ -n "$token" ]] || { echo "uso: $0 <token>" >&2; exit 2; }
case "$token" in
    glpat-*) tipo='acesso pessoal/projeto/grupo' ;;
    gldt-*)  tipo='deploy token' ;;
    glrt-*)  tipo='runner' ;;
    glcbt-*) tipo='ci job token' ;;
    glptt-*) tipo='gatilho de pipeline' ;;
    glft-*)  tipo='feed' ;;
    *)       echo "desconhecido" >&2; exit 1 ;;
esac
printf '%s · %s…\n' "$tipo" "${token:0:9}"
