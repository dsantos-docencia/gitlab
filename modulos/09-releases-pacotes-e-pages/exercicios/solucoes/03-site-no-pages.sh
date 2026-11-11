#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 09.03 — Documentação no GitLab Pages · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
documentacao:
  image: alpine:3.22
  script:
    - mkdir -p public
    - echo '<h1>Documentação da Loja</h1>' > public/index.html
  pages:
    publish: public            # qualquer job vira o de Pages com a palavra-chave pages
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH   # MR nenhum sobrescreve o site oficial
YAML
