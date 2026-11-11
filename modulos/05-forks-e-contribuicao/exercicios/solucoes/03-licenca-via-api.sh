#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 05.03 — Licença preenchida pela API · SOLUÇÃO COMENTADA
set -euo pipefail

chave="${1:-}" projeto="${2:-}" nome="${3:-}"
[[ -n "$chave" && -n "$projeto" && -n "$nome" ]] || { echo "uso: $0 <chave> <projeto> <nome>" >&2; exit 2; }
enc() { jq -rn --arg v "$1" '$v | @uri'; }
# Primeiro guardamos a resposta; só gravamos o arquivo se a chamada deu certo.
if ! json="$(glab api "templates/licenses/$chave?project=$(enc "$projeto")&fullname=$(enc "$nome")")"; then
    echo "erro: licença '$chave' não encontrada" >&2
    exit 1
fi
jq -r .content <<<"$json" > LICENSE
