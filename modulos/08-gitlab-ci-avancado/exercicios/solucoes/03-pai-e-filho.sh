#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 08.03 — Pipeline pai-filho para um monorepo · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
frontend:
  trigger:
    include: frontend/.gitlab-ci.yml
    strategy: depend          # o pai espera o filho e herda o status
  rules:
    - changes: [frontend/**/*]   # só quando o frontend mudou
YAML
mkdir -p frontend
cat > frontend/.gitlab-ci.yml <<'YAML'
testes-frontend:
  image: node:22-alpine
  script:
    - cd frontend && npm ci && npm test
YAML
