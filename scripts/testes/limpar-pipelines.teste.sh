# shellcheck shell=bash
teste_simula() {
    executar aluno/laboratorio --antes-de 2026-10-01; afirmar_status 0
    afirmar_chamou_glab "api --paginate 'projects/aluno%2Flaboratorio/pipelines?updated_before=2026-10-01T00:00:00Z&per_page=100'"
    afirmar_contem "(simulação) apagaria #8800  main  success  2026-08-01" "$SAIDA"
    afirmar_nao_contem "#9001" "$SAIDA" "pipeline recente fica"
    afirmar_nao_chamou_glab 'api -X DELETE *'
}
teste_aplica() {
    executar aluno/laboratorio --antes-de 2026-12-01 --aplicar
    afirmar_chamou_glab 'api -X DELETE projects/aluno%2Flaboratorio/pipelines/8800'
    afirmar_chamou_glab 'api -X DELETE projects/aluno%2Flaboratorio/pipelines/9000'
    afirmar_contem "3 pipelines anteriores a 2026-12-01 apagados" "$SAIDA"
}
teste_manter_padrao() {
    executar aluno/laboratorio --antes-de 2026-12-01 --manter-padrao --aplicar
    afirmar_chamou_glab 'api -X DELETE */pipelines/9000' "feature/login pode ir"
    afirmar_nao_chamou_glab 'api -X DELETE */pipelines/8800' "main fica com --manter-padrao"
}
teste_nao_apaga_rodando() {
    simular_glab 'api --paginate projects/*/pipelines*' '[{"id":1,"ref":"x","status":"running","created_at":"2020-01-01T00:00:00Z"}]'
    executar a/b --antes-de 2026-01-01 --aplicar
    afirmar_nao_chamou_glab 'api -X DELETE *'
}
teste_uso() { executar; afirmar_status 2; executar a/b --dias x; afirmar_status 2; executar a/b --antes-de 01/02/2026; afirmar_status 2; }
