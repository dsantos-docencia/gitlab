# shellcheck shell=bash
teste_limpo() {
    cat > .gitlab-ci.yml <<'YAML'
include:
  - project: escola-dev/ci
    ref: v1.4.0
    file: node.yml
  - component: $CI_SERVER_FQDN/escola-dev/componentes/testes@1.2.0
testes:
  image: node:22-alpine
  variables: {API_TOKEN: $TOKEN_DA_LOJA}
  script: [npm test]
deploy:
  image: alpine@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1
  environment: producao
  rules:
    - if: $CI_COMMIT_TAG
  script: [./deploy.sh]
YAML
    executar; afirmar_status 0; afirmar_contem "✔ .gitlab-ci.yml" "$SAIDA"
}
teste_achados() {
    cat > ci.yml <<'YAML'
variables:
  DB_PASSWORD: "hunter2"
  CI_DEBUG_TRACE: "true"
default:
  image: python
include:
  - project: escola-dev/ci
    file: node.yml
  - remote: https://exemplo.dev/ci.yml
  - component: gitlab.com/escola-dev/componentes/testes@~latest
testes:
  image: node:latest
  services: [postgres]
  script: [npm test]
deploy:
  image: alpine:3.22
  environment: {name: producao}
  script: [./deploy.sh]
YAML
    executar ci.yml; afirmar_status 1
    afirmar_contem "global: variável DB_PASSWORD com valor no YAML" "$SAIDA"
    afirmar_contem "CI_DEBUG_TRACE ligado" "$SAIDA"
    afirmar_contem "default: imagem sem versão: python" "$SAIDA"
    afirmar_contem "include: project escola-dev/ci sem ref fixo" "$SAIDA"
    afirmar_contem "include: remote https://exemplo.dev/ci.yml" "$SAIDA"
    afirmar_contem "componente sem versão fixa: gitlab.com/escola-dev/componentes/testes@~latest" "$SAIDA"
    afirmar_contem "job testes: imagem em :latest: node:latest" "$SAIDA"
    afirmar_contem "job testes: imagem sem versão: postgres" "$SAIDA" "services também"
    afirmar_contem "job deploy: implanta em 'producao' sem rules nem when: manual" "$SAIDA"
}
teste_varios_arquivos() {
    printf 'a:\n  image: alpine:3.22\n  script: [x]\n' > a.yml
    printf 'b:\n  image: alpine\n  script: [x]\n' > b.yml
    executar a.yml b.yml; afirmar_status 1
    afirmar_contem "✔ a.yml" "$SAIDA"; afirmar_contem "✘ b.yml" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2 "sem .gitlab-ci.yml no diretório"; }
