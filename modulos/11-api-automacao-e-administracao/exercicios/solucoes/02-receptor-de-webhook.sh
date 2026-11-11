#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.02 — Receptor de webhook seguro · SOLUÇÃO COMENTADA
set -euo pipefail

TOKEN="${1:-}"
[[ -n "${WEBHOOK_SEGREDO:-}" && -n "$TOKEN" ]] || { echo "uso: WEBHOOK_SEGREDO=... $0 TOKEN_RECEBIDO < evento.json" >&2; exit 2; }
if [[ "$TOKEN" != "$WEBHOOK_SEGREDO" ]]; then
    echo "token inválido" >&2; exit 1           # nada é processado com token errado
fi

EVENTO="$(cat)"
jq -r '
  if .object_kind == "merge_request" and .object_attributes.action == "merge" then
      "MR !\(.object_attributes.iid) mesclado em \(.object_attributes.target_branch) por \(.user.username)"
  elif .object_kind == "push" then
      "push em \(.ref | sub("^refs/heads/"; "")): \(.total_commits_count) commit(s)"
  elif .object_kind == "pipeline" and .object_attributes.status == "failed" then
      "ALERTA pipeline \(.object_attributes.id) falhou em \(.object_attributes.ref)"
  else
      "ignorado: \(.object_kind)"
  end' <<<"$EVENTO"
