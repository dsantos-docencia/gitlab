#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 11.02 — Receptor de webhook seguro. Enunciado: README.md desta pasta

# TODO: valide; compare o token; leia o JSON da entrada; decida pelo object_kind
# shellcheck disable=SC2034  # apague esta linha quando usar as variáveis
TOKEN="${1:-}"
