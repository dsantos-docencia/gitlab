# shellcheck shell=bash
# Testes do exercício 08.02 — Um componente de CI/CD e quem o usa
T=templates/testes.yml
C=.gitlab-ci.yml
teste_dois_documentos() {
    executar; afirmar_arquivo "$T"
    afirmar_jq "$T" 'type == "array" and length == 2' "o componente precisa de DOIS documentos separados por ---"
}
teste_spec() {
    executar
    afirmar_jq "$T" '.[0].spec.inputs.stage.default == "test"'
    afirmar_jq "$T" '.[0].spec.inputs.versao_node | .type == "string" and .default == "22"'
}
teste_corpo() {
    executar
    afirmar_jq "$T" '.[1]."testes-node".stage == "$[[ inputs.stage ]]"'
    afirmar_jq "$T" '.[1]."testes-node".image == "node:$[[ inputs.versao_node ]]-alpine"'
    afirmar_jq "$T" 'any(.[1]."testes-node".script[]; contains("npm test"))'
}
teste_quem_usa() {
    executar; afirmar_arquivo "$C"
    afirmar_jq "$C" '.include | length == 1'
    afirmar_jq "$C" '.include[0].component == "$CI_SERVER_FQDN/escola-dev/componentes/testes@1.2.0"' "versão fixa @1.2.0 (nada de @~latest ou @main)"
    afirmar_jq "$C" '.include[0].inputs.versao_node == "24"' 'versao_node: "24" (texto)'
    afirmar_schema_gitlab_ci "$C"
}
