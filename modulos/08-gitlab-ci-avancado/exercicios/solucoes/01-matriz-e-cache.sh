#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 08.01 — Matriz com cache por lockfile · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
testes:
  image: node:$VERSAO_NODE-alpine
  parallel:
    matrix:
      - VERSAO_NODE: ["20", "22", "24"]   # 3 × 2 = 6
        BANCO: [postgres, mysql]
      - VERSAO_NODE: "24"                 # + 1 = 7
        BANCO: sqlite
  cache:
    key:
      files: [package-lock.json]          # lockfile mudou → cache novo
    paths: [.npm/]
  script:
    - npm ci --cache .npm
    - npm test
YAML
