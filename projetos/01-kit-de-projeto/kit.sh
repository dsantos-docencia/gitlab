#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Projeto 01 · Kit de projeto
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Deixa um projeto "pronto para time" em um comando: templates de issue e MR,
#  CODEOWNERS com seções, pipeline com regras e scanners, e — pela API —
#  configurações de merge e proteção da branch padrão e das tags v*.
#  Idempotente: rodar duas vezes dá o mesmo resultado. Junta os Módulos
#  02, 03, 04, 06, 07 e 10.
#
#  USO
#    kit.sh GRUPO/PROJETO [--pasta DIR] [--sem-api] [--forcar]
#      --pasta DIR  clone local onde os arquivos são criados (padrão: .)
#      --sem-api    só cria os arquivos; não mexe nas configurações remotas
#      --forcar     sobrescreve arquivos que já existem
# ============================================================================
set -euo pipefail

projeto='' pasta='.' api=1 forcar=0
while (( $# )); do
    case "$1" in
        --pasta)   pasta="${2:?--pasta precisa de um diretório}"; shift ;;
        --sem-api) api=0 ;;
        --forcar)  forcar=1 ;;
        -h|--help) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)        echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)         projeto="$1" ;;
    esac
    shift
done
[[ "$projeto" =~ ^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)+$ ]] || { echo "uso: $0 GRUPO/PROJETO [--pasta DIR] [--sem-api] [--forcar]" >&2; exit 2; }
[[ -d "$pasta" ]] || { echo "erro: pasta não existe: $pasta" >&2; exit 2; }

# grava ARQUIVO < conteúdo — respeita o que já existe (a não ser com --forcar)
grava() {
    local destino="$pasta/$1"
    if [[ -e "$destino" && "$forcar" == 0 ]]; then
        cat >/dev/null; printf '  • mantido  %s\n' "$1"; return
    fi
    mkdir -p -- "$(dirname -- "$destino")"
    cat > "$destino"; printf '  ✔ criado   %s\n' "$1"
}

echo "Arquivos em $pasta"
grava .gitlab/issue_templates/Bug.md <<'MD'
## O que aconteceu

## Como reproduzir
1.
2.

## O que era esperado

## Ambiente (versão, navegador, sistema)

/label ~bug ~"precisa-triagem"
MD

grava .gitlab/merge_request_templates/Default.md <<'MD'
## O que muda e por quê

Closes #

## Como testar

## Checklist
- [ ] Testes cobrindo a mudança
- [ ] Documentação atualizada
- [ ] Sem segredos, tokens ou dados pessoais no diff
MD

grava .gitlab/CODEOWNERS <<'MD'
# Quem revisa o quê. Seções: [Nome][aprovações] @dono-padrão
[Geral] @aluno
*

[Pipeline e segurança][1] @aluno
/.gitlab-ci.yml
/.gitlab/

^[Documentação]
/docs/
*.md
MD

grava .gitlab-ci.yml <<'YAML'
# Gerado pelo kit do Curso de GitLab — ajuste o job "testes" ao seu projeto.
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never                     # evita pipeline duplicado (branch + MR)
    - if: $CI_COMMIT_BRANCH
    - if: $CI_COMMIT_TAG

stages: [test]

include:
  - template: Jobs/Secret-Detection.gitlab-ci.yml
  - template: Jobs/SAST.gitlab-ci.yml

testes:
  stage: test
  image: alpine:3.22
  script:
    - echo "troque por npm test, pytest ou go test"
YAML

(( api )) || { echo "Configurações remotas: puladas (--sem-api)"; exit 0; }

enc="$(jq -rn --arg v "$projeto" '$v | @uri')"
echo "Configurações de $projeto"

# 1) Regras de merge (PUT é idempotente: mesmo valor, mesmo resultado).
glab api -X PUT "projects/$enc" \
    -F only_allow_merge_if_pipeline_succeeds=true \
    -F only_allow_merge_if_all_discussions_are_resolved=true \
    -F remove_source_branch_after_merge=true \
    -f squash_option=default_on >/dev/null
echo "  ✔ merge só com pipeline verde e discussões resolvidas"

# 2) Branch padrão: a API recusa um 2º POST (409), então DELETE + POST.
padrao="$(glab api "projects/$enc" | jq -r '.default_branch // "main"')"
penc="$(jq -rn --arg v "$padrao" '$v | @uri')"
glab api -X DELETE "projects/$enc/protected_branches/$penc" >/dev/null 2>&1 || true
glab api -X POST "projects/$enc/protected_branches" -f name="$padrao" \
    -F push_access_level=40 -F merge_access_level=30 -F allow_force_push=false >/dev/null
echo "  ✔ $padrao protegida: push só Maintainers, merge Developers+, sem force push"

# 3) Tags de versão: só Maintainers criam v*.
glab api -X DELETE "projects/$enc/protected_tags/v%2A" >/dev/null 2>&1 || true
glab api -X POST "projects/$enc/protected_tags" -f 'name=v*' -F create_access_level=40 >/dev/null
echo "  ✔ tags v* protegidas (só Maintainers)"
