#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 05.02 — Sincronizar o fork · SOLUÇÃO COMENTADA
set -euo pipefail

url="${1:?uso: $0 <url-do-upstream>}"
cd meu-fork
git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$url"
git fetch -q upstream
git switch -q main
git merge -q --ff-only upstream/main      # divergiu? falha aqui (set -e) e nada é enviado
git push -q origin main
echo "fork sincronizado em $(git rev-parse --short HEAD)"
