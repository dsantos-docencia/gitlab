#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 08.02 — Um componente de CI/CD e quem o usa · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p templates
# Documento 1: a interface (spec). Documento 2: o corpo, que usa $[[ inputs.* ]].
cat > templates/testes.yml <<'YAML'
spec:
  inputs:
    stage:
      default: test
    versao_node:
      type: string
      default: "22"
      description: Versão do Node
---
testes-node:
  stage: $[[ inputs.stage ]]
  image: node:$[[ inputs.versao_node ]]-alpine
  script:
    - npm ci
    - npm test
YAML
# Versão FIXA (@1.2.0): o pipeline só muda quando você decidir.
cat > .gitlab-ci.yml <<'YAML'
include:
  - component: $CI_SERVER_FQDN/escola-dev/componentes/testes@1.2.0
    inputs:
      versao_node: "24"
YAML
