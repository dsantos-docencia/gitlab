# shellcheck shell=bash
teste_sucesso() {
    executar escola-dev/loja --var AMBIENTE=homologacao --var 'MSG=olá mundo' --intervalo 0
    afirmar_status 0
    afirmar_chamou_glab 'api -X POST projects/escola-dev%2Floja/pipeline -H*--input -'
    local corpo; corpo="$(entrada_glab 'api -X POST*')"
    jq -e '.ref == "main" and .variables == [{"key":"AMBIENTE","value":"homologacao"},{"key":"MSG","value":"olá mundo"}]' <<<"$corpo" >/dev/null \
        || _falhar "corpo JSON inesperado" "$corpo"
    afirmar_chamou_glab 'api projects/escola-dev%2Floja/pipelines/9100'
    afirmar_contem "pipeline 9100 disparado em main" "$SAIDA"
    afirmar_contem "success" "$SAIDA"
}
teste_ref_sem_variaveis() {
    executar a/b --ref release/2.x --intervalo 0
    jq -e '.ref == "release/2.x" and .variables == []' <<<"$(entrada_glab 'api -X POST*')" >/dev/null || _falhar "corpo inesperado"
}
teste_falha() {
    simular_glab 'api projects/*/pipelines/*' '{"id":9100,"status":"failed"}'
    executar a/b --intervalo 0; afirmar_status 1
}
teste_limite() {
    simular_glab 'api projects/*/pipelines/*' '{"id":9100,"status":"running"}'
    executar a/b --intervalo 0 --limite 0; afirmar_status 3 "3 = passou do limite (124 é reservado ao timeout do corretor)"
}
teste_uso() { executar; afirmar_status 2; executar a/b --var SEMIGUAL; afirmar_status 2; }
