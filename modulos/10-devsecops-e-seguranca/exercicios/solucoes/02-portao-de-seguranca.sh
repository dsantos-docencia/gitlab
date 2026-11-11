#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.02 — Portão de segurança (funciona no Free) · SOLUÇÃO COMENTADA
set -euo pipefail

REL="${1:-}"
[[ -n "$REL" && -f "$REL" ]] || { echo "uso: $0 gl-sast-report.json" >&2; exit 2; }

for s in Critical High Medium Low; do
    printf '%s: %s\n' "$s" "$(jq --arg s "$s" '[.vulnerabilities[] | select(.severity == $s)] | length' "$REL")"
done

# As que reprovam o pipeline, com o local exato para quem vai corrigir.
jq -r '.vulnerabilities[] | select(.severity == "Critical" or .severity == "High")
       | "BLOQUEIA \(.severity) \(.location.file):\(.location.start_line) \(.name)"' "$REL"

# jq -e: status 1 se o resultado for false → vira a saída do script.
if jq -e 'any(.vulnerabilities[]; .severity == "Critical" or .severity == "High")' "$REL" >/dev/null; then
    exit 1
fi
echo "nenhuma Critical/High — pode seguir"
