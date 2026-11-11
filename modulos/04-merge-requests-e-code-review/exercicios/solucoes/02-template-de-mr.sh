#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 04.02 — Template de merge request · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .gitlab/merge_request_templates
cat > .gitlab/merge_request_templates/Default.md <<'MD'
## O que muda

## Por quê
Closes #NUMERO

## Como testar

## Checklist
- [ ] Pipeline verde
- [ ] Revisei o meu próprio diff
- [ ] Documentação atualizada, se necessário

/assign me
/label ~"status::revisão"
MD
