#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 07.02 — Um job que conversa com o pipeline · SOLUÇÃO COMENTADA
set -euo pipefail

v="$(cat VERSION 2>/dev/null || true)"
if ! [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
    echo "ERRO: versão inválida: $v" >&2
    exit 1
fi
# \e[0K limpa a linha; o GitLab reconhece "section_start:<época>:<nome>" e
# desenha um bloco recolhível no log.
echo -e "\e[0Ksection_start:$(date +%s):versao[collapsed=true]\r\e[0KCalculando a versão"
pre=false
[[ "$v" == *-* ]] && pre=true
printf 'VERSAO=%s\nPRERELEASE=%s\n' "$v" "$pre" > build.env
echo "versão $v (pré-lançamento: $pre)"
echo -e "\e[0Ksection_end:$(date +%s):versao\r\e[0K"
