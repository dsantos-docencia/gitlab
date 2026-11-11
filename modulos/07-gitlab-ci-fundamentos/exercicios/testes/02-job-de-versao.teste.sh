# shellcheck shell=bash
# Testes do exercício 07.02 — Um job que conversa com o pipeline
teste_estavel() {
    printf '1.4.0\n' > VERSION; executar
    afirmar_status 0
    afirmar_igual $'VERSAO=1.4.0\nPRERELEASE=false' "$(cat build.env)"
}
teste_pre() {
    printf '2.0.0-rc.1\n' > VERSION; executar
    afirmar_igual $'VERSAO=2.0.0-rc.1\nPRERELEASE=true' "$(cat build.env)"
}
teste_secao() {
    printf '1.0.0\n' > VERSION; executar
    afirmar_casa 'section_start:[0-9]+:versao' "$SAIDA" "falta o section_start:<timestamp>:versao"
    afirmar_casa 'section_end:[0-9]+:versao' "$SAIDA" "falta o section_end:<timestamp>:versao"
}
teste_invalida() {
    printf 'v1.0\n' > VERSION; executar
    afirmar_status 1; afirmar_contem "ERRO: versão inválida: v1.0" "$ERRO"
    [[ -e build.env ]] && _falhar "não crie build.env com versão inválida"; return 0
}
teste_sem_arquivo() { executar; afirmar_status 1; }
