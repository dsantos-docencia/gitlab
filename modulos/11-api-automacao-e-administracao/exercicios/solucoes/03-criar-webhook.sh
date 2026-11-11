#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.03 — Criar webhook sem duplicar · SOLUÇÃO COMENTADA
set -euo pipefail

PROJETO="${1:-}" URL="${2:-}"
[[ -n "$PROJETO" && "$URL" == https://* && -n "${WEBHOOK_SEGREDO:-}" ]] || {
    echo "uso: WEBHOOK_SEGREDO=... $0 grupo/projeto https://url" >&2; exit 2; }
ENC="$(jq -rn --arg v "$PROJETO" '$v | @uri')"

HOOKS="$(glab api "projects/$ENC/hooks")"
# Webhooks que o GitLab desligou por falhas seguidas: ninguém percebe sozinho.
jq -r '.[] | select(.alert_status == "disabled") | "ATENÇÃO webhook \(.id) desativado: \(.url)"' <<<"$HOOKS" >&2

if jq -e --arg u "$URL" 'any(.[]; .url == $u)' <<<"$HOOKS" >/dev/null; then
    echo "já existe"; exit 0
fi
# -F manda tipado (booleano de verdade); -f manda texto.
glab api -X POST "projects/$ENC/hooks" -f url="$URL" -f token="$WEBHOOK_SEGREDO" \
    -F merge_requests_events=true -F pipeline_events=true -F push_events=false \
    -F enable_ssl_verification=true >/dev/null
echo "webhook criado: $URL"
