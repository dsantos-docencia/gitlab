# shellcheck shell=bash
# Testes do exercício 03.01 — Templates de issue com quick actions
D=.gitlab/issue_templates
teste_bug() {
    executar; afirmar_arquivo "$D/Bug.md"
    afirmar_igual $'## Passos para reproduzir\n## Comportamento esperado\n## Comportamento atual' "$(grep '^## ' "$D/Bug.md")" "as três seções, nesta ordem"
    afirmar_igual "/label ~bug" "$(grep -v '^\s*$' "$D/Bug.md" | tail -1)" "o template deve terminar com /label ~bug"
}
teste_seguranca() {
    executar; afirmar_arquivo "$D/Seguranca.md"
    grep -qx '/label ~"segurança"' "$D/Seguranca.md" || _falhar 'falta /label ~"segurança" (com aspas: o nome tem acento)'
    grep -qx '/confidential' "$D/Seguranca.md" || _falhar "falta /confidential"
    grep -q '^## O que você encontrou' "$D/Seguranca.md" || _falhar "falta a seção"
}
teste_default() {
    executar; afirmar_arquivo "$D/Default.md" "o nome precisa ser exatamente Default.md"
    grep -qx '/label ~"status::triagem"' "$D/Default.md" || _falhar 'falta /label ~"status::triagem"'
}
