# shellcheck shell=bash
teste_tres_secoes() {
    executar; afirmar_status 0
    afirmar_contem "Fila de aluno" "$SAIDA"
    afirmar_chamou_glab 'mr list --reviewer=@me --output json'
    afirmar_chamou_glab 'mr list --author=@me --output json'
    afirmar_chamou_glab 'issue list --assignee=@me --output json'
    afirmar_contem "👀 Revisões pedidas a você (3)" "$SAIDA"
    afirmar_contem "  aluno/laboratorio!7  feat: login com e-mail  · bia-dev, 2026-11-02" "$SAIDA"
    afirmar_contem "[rascunho]" "$SAIDA"
    afirmar_contem "  #12  Erro 500 ao salvar o perfil  [bug, prioridade::alta]  → v1.1" "$SAIDA"
}
teste_escopo() {
    executar -g escola-dev
    afirmar_chamou_glab 'mr list --reviewer=@me -g escola-dev --output json'
    executar -R escola-dev/loja
    afirmar_chamou_glab 'issue list --assignee=@me -R escola-dev/loja --output json'
}
teste_uso() { executar -R; afirmar_status 2; executar --bobagem; afirmar_status 2; }
