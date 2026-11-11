# shellcheck shell=bash
# Testes do exercício 05.01 — Checklist do projeto pronto para contribuições
completo() {
    mkdir -p p/docs p/.gitlab/issue_templates p/.gitlab/merge_request_templates
    touch p/README.md p/LICENSE p/docs/CONTRIBUTING.md p/CHANGELOG.md p/docs/SECURITY.md \
          p/.gitlab/issue_templates/Bug.md p/.gitlab/merge_request_templates/Default.md
}
teste_completo() {
    completo; executar p
    afirmar_status 0
    afirmar_igual $'✔ README\n✔ LICENSE\n✔ CONTRIBUTING\n✔ CHANGELOG\n✔ SECURITY\n✔ ISSUE_TEMPLATES\n✔ MR_TEMPLATES\nnota: 7/7' "$SAIDA"
}
teste_pasta_de_template_vazia_nao_conta() {
    completo; rm p/.gitlab/merge_request_templates/Default.md
    executar p
    afirmar_status 1; afirmar_contem "✘ MR_TEMPLATES" "$SAIDA"
}
teste_faltando() {
    mkdir q; touch q/README.md q/LICENSE.md
    executar q
    afirmar_igual "nota: 2/7" "$(tail -1 <<<"$SAIDA")"
}
teste_padrao_e_inexistente() {
    touch README.md; executar; afirmar_contem "✔ README" "$SAIDA"
    executar nada; afirmar_status 2
}
