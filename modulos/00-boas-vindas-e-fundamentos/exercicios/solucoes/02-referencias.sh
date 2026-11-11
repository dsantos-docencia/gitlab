#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 00.02 — Gerador de referências do GitLab · SOLUÇÃO COMENTADA
set -euo pipefail

tipo="${1:-}" valor="${2:-}"
[[ -n "$tipo" && -n "$valor" ]] || { echo "uso: $0 <issue|mr|epico|snippet|label|milestone> <valor>" >&2; exit 2; }

numero() { [[ "$valor" =~ ^[0-9]+$ ]] || { echo "erro: '$valor' não é um número" >&2; exit 1; }; }
# Nomes com espaço precisam de aspas na referência: ~"precisa de revisão".
nome() { if [[ "$valor" == *" "* ]]; then printf '"%s"' "$valor"; else printf '%s' "$valor"; fi; }

case "$tipo" in
    issue)     numero; echo "#$valor" ;;
    mr)        numero; echo "!$valor" ;;
    epico)     numero; echo "&$valor" ;;
    snippet)   numero; echo "\$$valor" ;;
    label)     echo "~$(nome)" ;;
    milestone) echo "%$(nome)" ;;
    *)         echo "tipo desconhecido: $tipo" >&2; exit 2 ;;
esac
