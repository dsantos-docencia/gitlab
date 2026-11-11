#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 07.03 — Pipeline agendado e manual · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
variables:
  DIAS:
    value: "7"                     # pré-preenchido no formulário "Run pipeline"
    description: Quantos dias olhar para trás no relatório

relatorio:
  image: alpine:3.22
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
    - if: $CI_PIPELINE_SOURCE == "web"
  script:
    - 'echo "Relatório dos últimos $DIAS dias"'
YAML
