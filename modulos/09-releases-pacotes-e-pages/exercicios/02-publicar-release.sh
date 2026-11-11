#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 09.02 — Script de publicação com changelog. Enunciado: README.md desta pasta

# TODO: valide "$1"; codifique o projeto; confira se já existe; busque as notas; crie a release
# shellcheck disable=SC2034  # apague esta linha quando usar as variáveis
VERSAO="${1:-}"
