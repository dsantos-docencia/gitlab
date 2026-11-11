# shellcheck shell=bash
# Testes do exercício 01.03 — Classificador de tokens do GitLab
T="glpat-abcdefghijklmnopqrst"
teste_pessoal() { executar "$T"; afirmar_igual "acesso pessoal/projeto/grupo · glpat-abc…" "$SAIDA"; }
teste_outros() {
    executar gldt-1234567890abcdefghij;  afirmar_igual "deploy token · gldt-1234…" "$SAIDA"
    executar glrt-1234567890abcdefghij;  afirmar_igual "runner · glrt-1234…" "$SAIDA"
    executar glcbt-1234567890abcdefghi;  afirmar_igual "ci job token · glcbt-123…" "$SAIDA"
    executar glptt-1234567890abcdefghi;  afirmar_igual "gatilho de pipeline · glptt-123…" "$SAIDA"
    executar glft-1234567890abcdefghij;  afirmar_igual "feed · glft-1234…" "$SAIDA"
}
teste_nao_vaza() {
    executar "$T"
    afirmar_nao_contem "$T" "$SAIDA$ERRO"; afirmar_nao_contem "defghij" "$SAIDA$ERRO"
}
teste_desconhecido() { executar ghp_abc; afirmar_status 1; afirmar_igual "" "$SAIDA"; }
teste_uso() { executar; afirmar_status 2; }
