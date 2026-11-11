# shellcheck shell=bash
# Testes do exercício 06.02 — Proteger as tags de versão
teste_tag_codificada() {
    executar escola-dev/loja
    afirmar_status 0
    afirmar_chamou_glab 'api projects/escola-dev%2Floja/protected_tags/v%2A' "o * da tag vira %2A na URL"
    afirmar_chamou_glab 'api -X DELETE projects/escola-dev%2Floja/protected_tags/v%2A'
}
teste_cria_com_nome_cru() {
    executar escola-dev/loja
    afirmar_chamou_glab "api -X POST projects/escola-dev%2Floja/protected_tags -f 'name=v*' -F create_access_level=40"
}
teste_outro_padrao() {
    simular_glab 'api projects/*/protected_tags/*' '{"message":"404"}' 1
    executar escola-dev/loja 'release-*'
    afirmar_nao_chamou_glab 'api -X DELETE*'
    afirmar_chamou_glab "api -X POST*-f 'name=release-*'*"
}
teste_uso() { executar; afirmar_status 2; }
