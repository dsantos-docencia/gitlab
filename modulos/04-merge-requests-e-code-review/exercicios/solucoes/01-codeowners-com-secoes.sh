#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 04.01 — CODEOWNERS com seções · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p .gitlab
cat > .gitlab/CODEOWNERS <<'TXT'
# Regras sem seção: a última que casar vence.
* @aluno

# Seção com dono padrão: as linhas sem dono herdam @bia-dev.
[Frontend] @bia-dev
*.js
*.css

[Documentação]
/docs/ @escola-dev/docs

# ^ = seção opcional: pede revisão, mas não bloqueia.
^[Opcional]
*.md @caio-qa
TXT
