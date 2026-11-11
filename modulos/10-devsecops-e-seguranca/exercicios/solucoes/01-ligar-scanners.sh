#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 10.01 — Os scanners no pipeline · SOLUÇÃO COMENTADA
set -euo pipefail

cat > .gitlab-ci.yml <<'YAML'
stages: [build, test]                 # os templates de segurança usam o estágio test

include:
  - template: Jobs/SAST.gitlab-ci.yml
  - template: Jobs/Secret-Detection.gitlab-ci.yml
  - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml   # v2: SBOM (GA no 19.0)

# Mesmo nome do job do template = os campos se fundem com os dele.
secret_detection:
  variables:
    SECRET_DETECTION_HISTORIC_SCAN: "true"   # 1ª execução: varre o histórico todo
YAML
