# shellcheck shell=bash
# Testes do exercício 05.03 — Licença preenchida pela API
teste_parametros_codificados() {
    executar mit "Loja do Bairro" "P&D Ana"
    afirmar_status 0
    afirmar_chamou_glab "api 'templates/licenses/mit?project=Loja%20do%20Bairro&fullname=P%26D%20Ana'" \
        "codifique os parâmetros: espaço → %20, & → %26"
}
teste_grava_o_content() {
    simular_glab 'api *templates/licenses/*' '{"key":"mit","content":"MIT License\n\nCopyright (c) 2026 Ana Dev\n"}'
    executar mit loja "Ana Dev"
    afirmar_igual $'MIT License\n\nCopyright (c) 2026 Ana Dev' "$(cat LICENSE)"
}
teste_api_falha() {
    simular_glab 'api *templates/licenses/*' '{"message":"404 Not Found"}' 1
    executar nada loja Ana
    afirmar_status 1
    [[ -e LICENSE ]] && _falhar "não deixe LICENSE quando a API falha"; return 0
}
teste_uso() { executar mit; afirmar_status 2; }
