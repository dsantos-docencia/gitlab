#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 00.03 — Deixando o glab do seu jeito · SOLUÇÃO COMENTADA
set -euo pipefail

# --global grava na configuração do usuário (vale para todos os projetos).
glab config set git_protocol ssh --global
glab config set editor "code --wait" --global
# Aspas simples: o shell não mexe no @me nem nos espaços.
glab alias set minhas 'issue list --assignee=@me'
glab alias set revisar 'mr list --reviewer=@me'
