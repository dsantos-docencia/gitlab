# shellcheck shell=bash
# Testes do exercício 08.03 — Pipeline pai-filho para um monorepo
teste_pai() {
    executar; afirmar_arquivo .gitlab-ci.yml
    afirmar_jq .gitlab-ci.yml '.frontend.trigger.include == "frontend/.gitlab-ci.yml"'
    afirmar_jq .gitlab-ci.yml '.frontend.trigger.strategy == "depend"' "strategy: depend (senão o pai fica verde com o filho vermelho)"
    afirmar_jq .gitlab-ci.yml 'any(.frontend.rules[]; .changes == ["frontend/**/*"])'
}
teste_filho() {
    executar; afirmar_arquivo frontend/.gitlab-ci.yml
    afirmar_jq frontend/.gitlab-ci.yml '."testes-frontend".image | contains(":") and (endswith(":latest") | not)'
    afirmar_jq frontend/.gitlab-ci.yml '(."testes-frontend".script | length) > 0'
}
teste_schema() {
    executar
    afirmar_schema_gitlab_ci .gitlab-ci.yml
    afirmar_schema_gitlab_ci frontend/.gitlab-ci.yml
}
