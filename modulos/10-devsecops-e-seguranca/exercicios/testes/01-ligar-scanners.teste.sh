# shellcheck shell=bash
# Testes do exercício 10.01 — Os scanners no pipeline
Y=.gitlab-ci.yml
teste_estagio() { executar; afirmar_arquivo "$Y"; afirmar_jq "$Y" '.stages | index("test") != null' "os templates exigem o estágio test"; }
teste_templates() {
    executar
    for t in Jobs/SAST.gitlab-ci.yml Jobs/Secret-Detection.gitlab-ci.yml Jobs/Dependency-Scanning.v2.gitlab-ci.yml; do
        afirmar_jq "$Y" "any(.include[]; .template == \"$t\")" "falta o template $t"
    done
}
teste_historico() {
    executar
    afirmar_jq "$Y" '.secret_detection.variables.SECRET_DETECTION_HISTORIC_SCAN == "true"' 'use "true" entre aspas (texto)'
}
