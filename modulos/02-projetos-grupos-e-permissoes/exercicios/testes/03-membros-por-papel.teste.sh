# shellcheck shell=bash
# Testes do exercício 02.03 — Membros por papel
teste_dados_de_exemplo() {
    executar aluno/laboratorio
    afirmar_status 0
    afirmar_igual $'Owner: aluno\nMaintainer: ex-estagiario\nDeveloper: bia-dev\nReporter: caio-qa\nPlanner: planejadora\n⚠ 2 pessoas podem alterar branches protegidas' "$SAIDA"
}
teste_paginado_e_codificado() {
    executar aluno/laboratorio
    afirmar_chamou_glab "api --paginate 'projects/aluno%2Flaboratorio/members/all?per_page=100'"
}
teste_ordem_alfabetica_e_sem_alerta() {
    simular_glab 'api *members*' '[{"username":"zeca","access_level":30},{"username":"ana","access_level":30},{"username":"dona","access_level":50}]'
    executar a/b
    afirmar_igual $'Owner: dona\nDeveloper: ana, zeca' "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; }
