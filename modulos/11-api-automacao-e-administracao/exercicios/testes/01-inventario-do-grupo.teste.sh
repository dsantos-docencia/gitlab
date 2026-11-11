# shellcheck shell=bash
# Testes do exercício 11.01 — Inventário de projetos do grupo
teste_csv() {
    executar escola-dev; afirmar_status 0
    afirmar_chamou_glab "api --paginate 'groups/escola-dev/projects?include_subgroups=true&per_page=100'"
    afirmar_igual "caminho,visibilidade,ultima_atividade
escola-dev/backend/api,internal,2026-11-01
escola-dev/loja,private,2026-11-09" "$SAIDA"
}
teste_subgrupo() {
    executar escola-dev/backend
    afirmar_chamou_glab "api --paginate 'groups/escola-dev%2Fbackend/projects?*"
}
teste_sem_arquivados() { executar escola-dev; afirmar_nao_contem "legado" "$SAIDA"; }
teste_uso() { executar; afirmar_status 2; }
