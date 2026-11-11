# shellcheck shell=bash
# Testes do Projeto 02 — auditor de projeto (dados do glab simulado)
teste_relatorio_padrao() {
    executar aluno/laboratorio
    afirmar_status 1 "nota 6 < mínimo padrão 7"
    afirmar_contem "✔ descrição preenchida" "$SAIDA"
    afirmar_contem "✔ branch padrão protegida, sem force push" "$SAIDA"
    afirmar_contem "✘ merge só com discussões resolvidas" "$SAIDA"
    afirmar_contem "✘ no máximo 1 pessoa Maintainer ou acima (aluno, ex-estagiario)" "$SAIDA"
    afirmar_contem "✘ variáveis sensíveis mascaradas e protegidas (API_SENHA, AWS_SECRET_ACCESS_KEY)" "$SAIDA"
    afirmar_contem "✘ nenhum webhook desativado" "$SAIDA"
    afirmar_igual "nota: 6/10" "$(tail -1 <<<"$SAIDA")"
}
teste_so_leitura() {
    executar aluno/laboratorio
    afirmar_nao_chamou_glab 'api -X *' "o auditor não altera nada"
    afirmar_chamou_glab "api 'projects/aluno%2Flaboratorio?license=true'"
}
teste_minimo() {
    executar aluno/laboratorio --minimo 6; afirmar_status 0
}
teste_json() {
    executar aluno/laboratorio --json --minimo 0
    jq -e '.nota == 6 and .total == 10 and (.itens | length) == 10 and .projeto == "aluno/laboratorio"' <<<"$SAIDA" >/dev/null || _falhar "JSON inesperado" "$SAIDA"
    jq -e '.itens[] | select(.item == "webhooks") | .ok == false' <<<"$SAIDA" >/dev/null || _falhar "webhooks deveria ser false"
}
teste_sem_protecao() {
    simular_glab 'api projects/*/protected_branches/*' '{"message":"404 Not found"}' 1
    executar aluno/laboratorio --minimo 0
    afirmar_contem "✘ branch padrão protegida, sem force push" "$SAIDA" "404 = não protegida"
}
teste_force_push() {
    simular_glab 'api projects/*/protected_branches/*' '{"name":"main","allow_force_push":true}'
    executar aluno/laboratorio --minimo 0
    afirmar_contem "✘ branch padrão protegida, sem force push" "$SAIDA"
}
teste_uso() {
    executar; afirmar_status 2
    executar a/b --minimo x; afirmar_status 2
    executar a/b --bobagem; afirmar_status 2
}
