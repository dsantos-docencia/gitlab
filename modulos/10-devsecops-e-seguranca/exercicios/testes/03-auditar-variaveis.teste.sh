# shellcheck shell=bash
# Testes do exercício 10.03 — Auditoria de variáveis de CI/CD
teste_riscos() {
    executar escola-dev/loja; afirmar_status 1
    afirmar_chamou_glab 'api projects/escola-dev%2Floja/variables'
    afirmar_contem "RISCO API_SENHA: não protegida" "$SAIDA"
    afirmar_contem "RISCO AWS_SECRET_ACCESS_KEY: sem máscara" "$SAIDA"
    afirmar_nao_contem "DEPLOY_TOKEN" "$SAIDA" "DEPLOY_TOKEN é masked e protected: está ok"
    afirmar_nao_contem "NODE_ENV" "$SAIDA" "NODE_ENV não é sensível"
}
teste_os_dois() {
    simular_glab 'api projects/*/variables*' '[{"key":"DB_PASSWORD","masked":false,"protected":false}]'
    executar a/b; afirmar_status 1
    afirmar_contem "RISCO DB_PASSWORD: sem máscara, não protegida" "$SAIDA"
}
teste_tudo_certo() {
    simular_glab 'api projects/*/variables*' '[{"key":"X_TOKEN","masked":true,"protected":true},{"key":"LOG_LEVEL","masked":false,"protected":false}]'
    executar a/b; afirmar_status 0
    afirmar_nao_contem "RISCO" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; }
