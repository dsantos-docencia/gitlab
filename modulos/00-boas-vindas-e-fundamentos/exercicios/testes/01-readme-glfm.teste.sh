# shellcheck shell=bash
# Testes do exercício 00.01 — README com recursos do GitLab
teste_toc() { executar; grep -qx '\[\[_TOC_\]\]' README.md || _falhar 'falta a linha [[_TOC_]] (sozinha)'; }
teste_titulo() { executar; grep -qE '^# [^#]' README.md || _falhar "falta um título de nível 1"; }
teste_alerta() {
    executar
    grep -q '^> \[!note\]' README.md || _falhar "falta '> [!note]'"
    grep -A1 '^> \[!note\]' README.md | tail -1 | grep -q '^> .' || _falhar "o alerta precisa de uma linha '> texto' logo abaixo"
}
teste_tarefas() {
    executar
    grep -q '^- \[x\] ' README.md || _falhar "falta '- [x]'"
    grep -q '^- \[ \] ' README.md || _falhar "falta '- [ ]'"
    grep -q '^- \[~\] ' README.md || _falhar "falta '- [~]' (tarefa não aplicável, exclusiva do GitLab)"
}
teste_mermaid() {
    executar
    grep -q '^```mermaid' README.md || _falhar 'falta o bloco ```mermaid'
    afirmar_igual "0" "$(( $(grep -c '^```' README.md) % 2 ))" 'bloco de código sem fechar (número ímpar de ```)'
}
