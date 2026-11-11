# shellcheck shell=bash
# Testes do exercício 02.02 — Regras de merge pela API
teste_caminho_codificado() {
    executar escola-dev/backend/api
    afirmar_status 0
    afirmar_chamou_glab 'api -X PUT projects/escola-dev%2Fbackend%2Fapi *' "o caminho precisa ir codificado: escola-dev%2Fbackend%2Fapi"
}
teste_metodo_e_squash() {
    executar escola-dev/loja
    afirmar_chamou_glab 'api -X PUT*-f merge_method=ff*'
    afirmar_chamou_glab 'api -X PUT*-f squash_option=default_on*'
}
teste_booleanos_tipados() {
    executar escola-dev/loja
    afirmar_chamou_glab 'api -X PUT*-F only_allow_merge_if_pipeline_succeeds=true*' "booleanos com -F (tipado)"
    afirmar_chamou_glab 'api -X PUT*-F only_allow_merge_if_all_discussions_are_resolved=true*'
    afirmar_chamou_glab 'api -X PUT*-F remove_source_branch_after_merge=true*'
}
teste_uma_chamada() { executar a/b; afirmar_igual "1" "$(contar_chamadas_glab 'api*')"; }
teste_uso() { executar loja; afirmar_status 2; afirmar_nao_chamou_glab '*'; }
