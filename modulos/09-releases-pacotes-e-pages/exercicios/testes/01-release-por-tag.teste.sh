# shellcheck shell=bash
# Testes do exercício 09.01 — Release automática a cada tag
Y=.gitlab-ci.yml
teste_imagem() {
    executar; afirmar_arquivo "$Y"
    afirmar_jq "$Y" '.release.image | startswith("registry.gitlab.com/gitlab-org/cli")' "use a imagem do glab (gitlab-org/cli)"
    afirmar_jq "$Y" '.release.image | contains("release-cli") | not' "a release-cli está depreciada"
}
teste_so_em_tag() { executar; afirmar_jq "$Y" 'any(.release.rules[]; .if == "$CI_COMMIT_TAG")'; }
teste_release() {
    executar
    afirmar_jq "$Y" '.release.release.tag_name == "$CI_COMMIT_TAG"'
    afirmar_jq "$Y" '.release.release.name == "Versão $CI_COMMIT_TAG"'
    afirmar_jq "$Y" '.release.release.description == "./NOTAS.md"'
}
teste_link() {
    executar
    afirmar_jq "$Y" 'any(.release.release.assets.links[]; .link_type == "package" and (.url | contains("/packages/generic/")))'
}
teste_schema() { executar; afirmar_schema_gitlab_ci "$Y"; }
