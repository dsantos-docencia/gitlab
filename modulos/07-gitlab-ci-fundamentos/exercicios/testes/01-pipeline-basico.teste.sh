# shellcheck shell=bash
# Testes do exercício 07.01 — Um pipeline correto e sem duplicação
Y=.gitlab-ci.yml
teste_workflow() {
    executar; afirmar_arquivo "$Y"
    afirmar_jq "$Y" '.workflow.rules[0].if == "$CI_PIPELINE_SOURCE == \"merge_request_event\""' "1ª regra: pipeline de MR"
    afirmar_jq "$Y" '.workflow.rules[1].if == "$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS" and .workflow.rules[1].when == "never"' "2ª regra: branch com MR aberto → when: never"
    afirmar_jq "$Y" '.workflow.rules[2].if == "$CI_COMMIT_BRANCH"'
}
teste_default() {
    executar
    afirmar_jq "$Y" '.stages == ["build","test"]'
    afirmar_jq "$Y" '.default.image | type == "string" and contains(":") and (endswith(":latest") | not)' "image com versão fixa (nada de :latest)"
    afirmar_jq "$Y" '.default.interruptible == true and (.default.timeout | type == "string")'
}
teste_jobs() {
    executar
    afirmar_jq "$Y" '.compilar.stage == "build" and (.compilar.artifacts.paths | index("dist/")) and (.compilar.artifacts.expire_in | length > 0)'
    afirmar_jq "$Y" '.testes.stage == "test" and .testes.needs == ["compilar"]'
    afirmar_jq "$Y" 'any(.testes.script[]; contains("./testes.sh"))'
}
teste_schema() { executar; afirmar_schema_gitlab_ci "$Y"; }
