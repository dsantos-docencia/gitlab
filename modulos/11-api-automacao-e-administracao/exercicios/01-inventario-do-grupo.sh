#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.01 — Inventário de projetos do grupo. Enunciado: README.md desta pasta

# TODO: valide "$1"; codifique; glab api --paginate ...; jq: filtre, ordene e monte o CSV
# shellcheck disable=SC2034  # apague esta linha quando usar as variáveis
GRUPO="${1:-}"
