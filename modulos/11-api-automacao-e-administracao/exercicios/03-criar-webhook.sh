#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.03 — Criar webhook sem duplicar. Enunciado: README.md desta pasta

# TODO: valide; codifique; liste; idempotência; crie; avise dos desativados
# shellcheck disable=SC2034  # apague esta linha quando usar as variáveis
PROJETO="${1:-}" URL="${2:-}"
