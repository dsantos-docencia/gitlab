# shellcheck shell=bash
# Testes do exercício 00.02 — Gerador de referências do GitLab
teste_numericos() {
    executar issue 12;  afirmar_igual "#12" "$SAIDA"
    executar mr 7;      afirmar_igual "!7" "$SAIDA"
    executar epico 3;   afirmar_igual "&3" "$SAIDA"
    executar snippet 5; afirmar_igual '$5' "$SAIDA"
}
teste_labels() {
    executar label bug;                  afirmar_igual "~bug" "$SAIDA"
    executar label "precisa de revisão"; afirmar_igual '~"precisa de revisão"' "$SAIDA"
}
teste_milestones() {
    executar milestone v1.1;       afirmar_igual "%v1.1" "$SAIDA"
    executar milestone "Sprint 4"; afirmar_igual '%"Sprint 4"' "$SAIDA"
}
teste_numero_invalido() { executar mr abc; afirmar_status 1; }
teste_tipo_desconhecido() { executar pr 3; afirmar_status 2; executar issue; afirmar_status 2; }
