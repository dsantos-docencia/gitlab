#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 07.01 — Um pipeline correto e sem duplicação · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never                     # o MR já tem pipeline: evita duplicar
    - if: $CI_COMMIT_BRANCH

stages: [build, test]

default:
  image: alpine:3.22                  # versão fixa: o pipeline não muda sozinho
  interruptible: true
  timeout: 10m

compilar:
  stage: build
  script:
    - ./build.sh
  artifacts:
    paths: [dist/]
    expire_in: 1 week

testes:
  stage: test
  needs: [compilar]
  script:
    - ./testes.sh
YAML
