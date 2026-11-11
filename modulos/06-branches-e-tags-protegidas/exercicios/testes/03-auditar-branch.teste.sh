# shellcheck shell=bash
# Testes do exercício 06.03 — Auditoria de uma branch protegida
teste_dados_de_exemplo() {
    executar aluno/laboratorio
    afirmar_status 1
    afirmar_igual $'✘ push direto bloqueado\n✔ merge restrito\n✔ force push bloqueado' "$SAIDA"
}
teste_tudo_ok() {
    simular_glab 'api projects/*/protected_branches/*' '{"name":"main","push_access_levels":[{"access_level":0}],"merge_access_levels":[{"access_level":30}],"allow_force_push":false}'
    executar a/b
    afirmar_status 0
}
teste_branch_codificada() {
    executar a/b release/1.0
    afirmar_chamou_glab 'api projects/a%2Fb/protected_branches/release%2F1.0'
}
teste_nao_protegida() {
    simular_glab 'api projects/*/protected_branches/*' '{"message":"404"}' 1
    executar a/b
    afirmar_status 1; afirmar_igual "✘ branch não protegida" "$SAIDA"
}
