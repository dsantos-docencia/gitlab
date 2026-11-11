# shellcheck shell=bash
# Testes do exercício 07.03 — Pipeline agendado e manual
Y=.gitlab-ci.yml
teste_variavel() {
    executar; afirmar_arquivo "$Y"
    afirmar_jq "$Y" '.variables.DIAS.value == "7"' 'value: "7" (texto, entre aspas)'
    afirmar_jq "$Y" '(.variables.DIAS.description | length) > 0'
}
teste_regras() {
    executar
    afirmar_jq "$Y" '[.relatorio.rules[].if] == ["$CI_PIPELINE_SOURCE == \"schedule\"","$CI_PIPELINE_SOURCE == \"web\""]'
    afirmar_jq "$Y" '.relatorio.image | contains(":") and (endswith(":latest") | not)'
}
teste_aspas() {
    executar
    afirmar_jq "$Y" 'any(.relatorio.script[]; contains("\"$DIAS\"") or contains("${DIAS}\"") or test("\"[^\"]*\\$DIAS[^\"]*\""))' 'use a variável entre aspas duplas'
}
teste_schema() { executar; afirmar_schema_gitlab_ci "$Y"; }
