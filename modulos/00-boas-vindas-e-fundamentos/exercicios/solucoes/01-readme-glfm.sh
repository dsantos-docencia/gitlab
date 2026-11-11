#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 00.01 — README com recursos do GitLab · SOLUÇÃO COMENTADA
set -euo pipefail

cat > README.md <<'MD'
# Meu Projeto

[[_TOC_]]

> [!note]
> README gerado por um script do Curso de GitLab.

## Tarefas
- [x] criar o projeto
- [ ] escrever os testes
- [~] suporte ao Internet Explorer

## Fluxo
```mermaid
graph LR
  Issue --> MR --> Pipeline
```
MD
