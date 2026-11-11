# shellcheck shell=bash
# Testes do exercício 04.02 — Template de merge request
T=.gitlab/merge_request_templates/Default.md
teste_secoes() {
    executar; afirmar_arquivo "$T"
    afirmar_igual $'## O que muda\n## Por quê\n## Como testar' "$(grep -E '^## (O que muda|Por quê|Como testar)$' "$T")"
}
teste_closes_e_checklist() {
    executar
    grep -q 'Closes #' "$T" || _falhar "falta a linha com 'Closes #'"
    (( $(grep -c '^- \[ \] ' "$T") >= 3 )) || _falhar "a checklist precisa de 3 itens '- [ ]'"
}
teste_quick_actions_no_final() {
    executar
    afirmar_igual $'/assign me\n/label ~"status::revisão"' "$(grep -v '^\s*$' "$T" | tail -2)" "as duas quick actions, no final"
}
