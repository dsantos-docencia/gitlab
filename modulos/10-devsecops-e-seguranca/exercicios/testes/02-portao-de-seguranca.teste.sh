# shellcheck shell=bash
# Testes do exercício 10.02 — Portão de segurança (funciona no Free)
relatorio() {   # relatorio ARQ SEV:ARQUIVO:LINHA:NOME ...
    local saida="$1"; shift
    printf '%s\n' "$@" | jq -R 'split(":") | {severity: .[0], name: .[3], location: {file: .[1], start_line: (.[2] | tonumber)}}' \
        | jq -s '{version: "15.2.1", vulnerabilities: .}' > "$saida"
}
teste_bloqueia() {
    relatorio r.json "High:app/login.py:42:SQL Injection" "Medium:app/util.py:7:Weak hash" "Critical:app/api.py:10:Command injection" "Low:a.py:1:Info"
    executar r.json; afirmar_status 1
    afirmar_contem "Critical: 1" "$SAIDA"; afirmar_contem "High: 1" "$SAIDA"
    afirmar_contem "Medium: 1" "$SAIDA"; afirmar_contem "Low: 1" "$SAIDA"
    afirmar_contem "BLOQUEIA High app/login.py:42 SQL Injection" "$SAIDA"
    afirmar_contem "BLOQUEIA Critical app/api.py:10 Command injection" "$SAIDA"
    afirmar_nao_contem "Weak hash" "$(grep BLOQUEIA <<<"$SAIDA" || true)" "Medium não bloqueia"
}
teste_ordem() {
    relatorio r.json "Low:a:1:x" "Critical:b:2:y"
    executar r.json
    afirmar_igual "Critical High Medium Low" "$(grep -oE '^(Critical|High|Medium|Low):' <<<"$SAIDA" | tr -d : | xargs)" "ordem: Critical, High, Medium, Low"
}
teste_libera() {
    relatorio r.json "Medium:x.py:3:Algo" "Low:y.py:4:Outro"
    executar r.json; afirmar_status 0
    afirmar_nao_contem "BLOQUEIA" "$SAIDA"
}
teste_vazio() { echo '{"version":"15.2.1","vulnerabilities":[]}' > r.json; executar r.json; afirmar_status 0; afirmar_contem "Critical: 0" "$SAIDA"; }
teste_uso() { executar; afirmar_status 2; executar nao-existe.json; afirmar_status 2; }
