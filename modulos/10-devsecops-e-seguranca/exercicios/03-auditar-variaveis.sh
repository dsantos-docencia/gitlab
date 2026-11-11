#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.03 — Auditoria de variáveis de CI/CD. Enunciado: README.md desta pasta

# TODO: valide "$1"; codifique; liste as variáveis; filtre as sensíveis; aponte o que falta
# shellcheck disable=SC2034  # apague esta linha quando usar as variáveis
PROJETO="${1:-}"
