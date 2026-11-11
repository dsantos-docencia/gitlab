#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 09.01 — Release automática a cada tag · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
release:
  stage: deploy
  image: registry.gitlab.com/gitlab-org/cli:latest   # glab: a release-cli sai no GitLab 20.0
  rules:
    - if: $CI_COMMIT_TAG                             # só quando uma tag é criada
  script:
    - echo "publicando $CI_COMMIT_TAG"
  release:
    tag_name: $CI_COMMIT_TAG
    name: Versão $CI_COMMIT_TAG
    description: ./NOTAS.md                          # caminho de arquivo também vale
    assets:
      links:
        - name: loja.tar.gz
          url: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/loja/${CI_COMMIT_TAG}/loja.tar.gz
          link_type: package
YAML
