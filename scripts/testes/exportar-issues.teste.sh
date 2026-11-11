# shellcheck shell=bash
teste_exporta() {
    executar aluno/laboratorio --destino bkp; afirmar_status 0
    afirmar_chamou_glab "api --paginate 'projects/aluno%2Flaboratorio/issues?state=all&per_page=100&order_by=created_at&sort=asc'"
    afirmar_arquivo bkp/issues.json; afirmar_arquivo bkp/INDICE.md
    afirmar_jq bkp/issues.json 'length == 4 and (map(.iid) == [9,10,11,12])' "ordenado por iid"
    afirmar_contem "| 12 | Erro 500 ao salvar o perfil | opened | bug, prioridade::alta | bia-dev | 2026-11-01 |" "$(cat bkp/INDICE.md)"
    afirmar_contem "4 issues exportados para bkp/" "$SAIDA"
}
teste_varias_paginas() {
    simular_glab 'api --paginate *' '[{"iid":2,"title":"b","state":"closed","labels":[],"assignees":[],"created_at":"2026-01-02"}]
[{"iid":1,"title":"a | b","state":"opened","labels":[],"assignees":[],"created_at":"2026-01-01"}]'
    executar a/b --destino d
    afirmar_jq d/issues.json 'length == 2 and .[0].iid == 1' "duas páginas viram uma lista"
    afirmar_contem 'a \| b' "$(cat d/INDICE.md)" "| no título é escapado na tabela"
}
teste_uso() { executar; afirmar_status 2; }
