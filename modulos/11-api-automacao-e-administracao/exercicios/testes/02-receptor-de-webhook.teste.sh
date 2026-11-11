# shellcheck shell=bash
# Testes do exercício 11.02 — Receptor de webhook seguro
export WEBHOOK_SEGREDO=s3gr3d0
teste_merge() {
    executar_com_entrada '{"object_kind":"merge_request","user":{"username":"bia-dev"},"object_attributes":{"iid":7,"action":"merge","target_branch":"main"}}' s3gr3d0
    afirmar_status 0; afirmar_igual "MR !7 mesclado em main por bia-dev" "$SAIDA"
}
teste_mr_aberto_e_ignorado() {
    executar_com_entrada '{"object_kind":"merge_request","object_attributes":{"iid":8,"action":"open"}}' s3gr3d0
    afirmar_igual "ignorado: merge_request" "$SAIDA"
}
teste_push() {
    executar_com_entrada '{"object_kind":"push","ref":"refs/heads/feature/csv","total_commits_count":3}' s3gr3d0
    afirmar_igual "push em feature/csv: 3 commit(s)" "$SAIDA"
}
teste_pipeline() {
    executar_com_entrada '{"object_kind":"pipeline","object_attributes":{"id":9100,"status":"failed","ref":"main"}}' s3gr3d0
    afirmar_igual "ALERTA pipeline 9100 falhou em main" "$SAIDA"
    executar_com_entrada '{"object_kind":"pipeline","object_attributes":{"id":9101,"status":"success","ref":"main"}}' s3gr3d0
    afirmar_igual "ignorado: pipeline" "$SAIDA"
}
teste_token_errado() {
    executar_com_entrada '{"object_kind":"push","ref":"refs/heads/main","total_commits_count":1}' chute
    afirmar_status 1; afirmar_contem "token inválido" "$ERRO"; afirmar_igual "" "$SAIDA" "nada processado"
}
teste_uso() {
    executar_com_entrada '{}'; afirmar_status 2
    WEBHOOK_SEGREDO='' executar_com_entrada '{}' x; afirmar_status 2
}
