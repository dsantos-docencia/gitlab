#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.03 — Auditoria de variáveis de CI/CD · SOLUÇÃO COMENTADA
set -euo pipefail

PROJETO="${1:-}"
[[ -n "$PROJETO" ]] || { echo "uso: $0 grupo/projeto" >&2; exit 2; }
ENC="$(jq -rn --arg v "$PROJETO" '$v | @uri')"

RISCOS="$(glab api "projects/$ENC/variables" | jq -r '
  .[] | select(.key | test("TOKEN|SENHA|PASSWORD|SECRET|KEY"))
      | [ (if .masked    then empty else "sem máscara"   end),
          (if .protected then empty else "não protegida" end) ] as $falta
      | select($falta | length > 0)
      | "RISCO \(.key): \($falta | join(", "))"')"

if [[ -n "$RISCOS" ]]; then
    printf '%s\n' "$RISCOS"; exit 1
fi
echo "nenhuma variável sensível exposta em $PROJETO"
