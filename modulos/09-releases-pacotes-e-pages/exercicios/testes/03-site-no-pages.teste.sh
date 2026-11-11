# shellcheck shell=bash
# Testes do exercício 09.03 — Documentação no GitLab Pages
Y=.gitlab-ci.yml
teste_pages() {
    executar; afirmar_arquivo "$Y"
    afirmar_jq "$Y" '.documentacao.pages.publish == "public"'
}
teste_so_na_padrao() {
    executar
    afirmar_jq "$Y" 'any(.documentacao.rules[]; .if == "$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH")'
}
teste_imagem_e_script() {
    executar
    afirmar_jq "$Y" '.documentacao.image | contains(":") and (endswith(":latest") | not)'
    afirmar_jq "$Y" 'any(.documentacao.script[]; contains("public/index.html"))'
}
teste_schema() { executar; afirmar_schema_gitlab_ci "$Y"; }
