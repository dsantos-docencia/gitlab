# shellcheck shell=bash
teste_por_papel() {
    executar aluno/laboratorio; afirmar_status 1
    afirmar_chamou_glab "api --paginate 'projects/aluno%2Flaboratorio/members/all?per_page=100'"
    afirmar_contem "  Owner       aluno" "$SAIDA"
    afirmar_contem "  Maintainer  ex-estagiario" "$SAIDA"
    afirmar_contem "  Planner     planejadora" "$SAIDA"
    afirmar_contem "⚠ 2 pessoas com Maintainer ou acima (máx. 1): aluno, ex-estagiario" "$SAIDA"
    afirmar_contem "⚠ ex-estagiario é Maintainer sem data de expiração" "$SAIDA"
}
teste_ordem_decrescente() {
    executar aluno/laboratorio
    afirmar_igual "Owner Maintainer Developer Reporter Planner" "$(sed -n '2,6p' <<<"$SAIDA" | awk '{print $1}' | xargs)"
}
teste_grupo_e_limite() {
    simular_glab 'api --paginate groups/*' '[{"username":"a","access_level":50,"state":"active"},{"username":"b","access_level":40,"state":"active","expires_at":"2027-01-01"},{"username":"c","access_level":30,"state":"blocked"}]'
    executar --grupo escola-dev --max-maintainers 2
    afirmar_chamou_glab "api --paginate 'groups/escola-dev/members/all?per_page=100'"
    afirmar_contem "⚠ conta blocked: c ainda tem acesso" "$SAIDA"
    afirmar_nao_contem "pessoas com Maintainer" "$SAIDA"
    afirmar_nao_contem "sem data de expiração" "$SAIDA"
}
teste_json() {
    executar aluno/laboratorio --json
    jq -e '.alvo == "aluno/laboratorio" and (.alertas | length) == 2 and .por_papel[0].papel == "Owner"' <<<"$SAIDA" >/dev/null || _falhar "JSON inesperado" "$SAIDA"
}
teste_tudo_certo() {
    simular_glab 'api --paginate *' '[{"username":"a","access_level":50,"state":"active"},{"username":"b","access_level":30,"state":"active"}]'
    executar a/b; afirmar_status 0; afirmar_contem "nenhum alerta" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; executar sem-barra; afirmar_status 2; }
