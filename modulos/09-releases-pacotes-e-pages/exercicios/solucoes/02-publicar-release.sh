#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 09.02 — Script de publicação com changelog · SOLUÇÃO COMENTADA
set -euo pipefail

VERSAO="${1:-}"
PROJETO="${PROJETO:-aluno/laboratorio}"
if [[ ! "$VERSAO" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "uso: $0 MAIOR.MENOR.CORREÇÃO  (ex.: 1.2.0)" >&2; exit 2
fi
TAG="v$VERSAO"
ENC="$(jq -rn --arg v "$PROJETO" '$v | @uri')"          # aluno/laboratorio → aluno%2Flaboratorio

# Idempotência: não tenta criar o que já existe (a API devolveria 409).
if glab api "projects/$ENC/releases" | jq -e --arg t "$TAG" 'any(.[]; .tag_name == $t)' >/dev/null; then
    echo "a release $TAG já existe em $PROJETO" >&2; exit 1
fi

# GET no changelog só gera o texto; não faz commit.
NOTAS="$(glab api "projects/$ENC/repository/changelog?version=$VERSAO" | jq -r '.notes')"
glab release create "$TAG" --notes "$NOTAS" --ref main -R "$PROJETO"
echo "release $TAG publicada"
