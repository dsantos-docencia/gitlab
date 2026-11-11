# shellcheck shell=bash
# Testes do exercício 08.01 — Matriz com cache por lockfile
Y=.gitlab-ci.yml
contar() {
    json_de "$Y" | python3 -c '
import itertools, json, sys
m = json.load(sys.stdin)["testes"]["parallel"]["matrix"]
print(sum(len(list(itertools.product(*[(v if isinstance(v, list) else [v]) for v in s.values()]))) for s in m))'
}
teste_sete_jobs() { executar; afirmar_arquivo "$Y"; afirmar_igual "7" "$(contar)" "a matriz deve gerar 7 jobs"; }
teste_eixos() {
    executar
    afirmar_jq "$Y" '.testes.parallel.matrix[0].VERSAO_NODE == ["20","22","24"]' 'VERSAO_NODE como TEXTO: ["20","22","24"]'
    afirmar_jq "$Y" '.testes.parallel.matrix[1].BANCO == "sqlite"'
    afirmar_jq "$Y" '.testes.image == "node:$VERSAO_NODE-alpine"'
}
teste_cache() {
    executar
    afirmar_jq "$Y" '.testes.cache.key.files == ["package-lock.json"] and .testes.cache.paths == [".npm/"]'
}
teste_schema() { executar; afirmar_schema_gitlab_ci "$Y"; }
