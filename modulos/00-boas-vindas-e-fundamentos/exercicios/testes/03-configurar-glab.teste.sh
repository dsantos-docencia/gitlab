# shellcheck shell=bash
# Testes do exercício 00.03 — Deixando o glab do seu jeito
teste_protocolo() {
    executar
    afirmar_chamou_glab 'config set git_protocol ssh*--global*' "glab config set git_protocol ssh --global"
}
teste_editor() {
    executar
    afirmar_chamou_glab "config set editor 'code --wait'*--global*" 'o editor "code --wait" é UM argumento (use aspas)'
}
teste_aliases() {
    executar
    afirmar_chamou_glab "alias set minhas 'issue list --assignee=@me'"
    afirmar_chamou_glab "alias set revisar 'mr list --reviewer=@me'"
}
