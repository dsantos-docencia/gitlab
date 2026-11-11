#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 03.01 — Templates de issue com quick actions · SOLUÇÃO COMENTADA
set -euo pipefail

d=.gitlab/issue_templates
mkdir -p "$d"
cat > "$d/Bug.md" <<'MD'
## Passos para reproduzir
1.

## Comportamento esperado

## Comportamento atual

/label ~bug
MD
# Label com acento/espaço: entre aspas na quick action.
cat > "$d/Seguranca.md" <<'MD'
## O que você encontrou
Descreva sem publicar dados de exploração.

/label ~"segurança"
/confidential
MD
# Default.md é aplicado automaticamente a todo issue novo.
cat > "$d/Default.md" <<'MD'
Descreva o que aconteceu e o que você esperava.

/label ~"status::triagem"
MD
