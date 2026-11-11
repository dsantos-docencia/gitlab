#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 05.01 — Checklist do projeto pronto para contribuições · SOLUÇÃO COMENTADA
set -euo pipefail

raiz="${1:-.}"
[[ -d "$raiz" ]] || { echo "erro: pasta não encontrada: $raiz" >&2; exit 2; }
nota=0
marcar() { if [[ "$2" == ok ]]; then echo "✔ $1"; nota=$((nota + 1)); else echo "✘ $1"; fi; }
arquivo() {   # arquivo NOME... → ok se algum existir na raiz ou em docs/
    local n
    for n in "$@"; do [[ -f "$raiz/$n" || -f "$raiz/docs/$n" ]] && { echo ok; return; }; done
    echo nao
}
templates() {   # templates PASTA → ok se houver ao menos um .md
    local arqs=("$raiz/.gitlab/$1"/*.md)
    [[ -e "${arqs[0]}" ]] && echo ok || echo nao
}
marcar README          "$(arquivo README.md)"
marcar LICENSE         "$(arquivo LICENSE LICENSE.md)"
marcar CONTRIBUTING    "$(arquivo CONTRIBUTING.md)"
marcar CHANGELOG       "$(arquivo CHANGELOG.md)"
marcar SECURITY        "$(arquivo SECURITY.md)"
marcar ISSUE_TEMPLATES "$(templates issue_templates)"
marcar MR_TEMPLATES    "$(templates merge_request_templates)"
echo "nota: $nota/7"
(( nota == 7 ))
