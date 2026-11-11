# shellcheck shell=bash
# Testes do exercício 05.02 — Sincronizar o fork
montar() {
    git init -q --bare upstream.git; git clone -q upstream.git tmp 2>/dev/null
    commitar README.md v1 "docs: v1" tmp; git -C tmp push -q origin main
    git clone -q --bare upstream.git fork.git; git clone -q fork.git meu-fork 2>/dev/null
    commitar README.md v2 "docs: v2" tmp; git -C tmp push -q origin main
}
teste_sincroniza() {
    montar; executar "$PWD/upstream.git"
    afirmar_status 0
    afirmar_igual "$(git -C upstream.git rev-parse main)" "$(git -C fork.git rev-parse main)"
    afirmar_contem "fork sincronizado em $(git -C upstream.git rev-parse --short main)" "$SAIDA"
}
teste_idempotente() { montar; executar "$PWD/upstream.git"; executar "$PWD/upstream.git"; afirmar_status 0; }
teste_divergiu() {
    montar; commitar x.txt x "feat: na main do fork" meu-fork; git -C meu-fork push -q origin main
    local antes; antes="$(git -C fork.git rev-parse main)"
    executar "$PWD/upstream.git"
    afirmar_status_diferente_de_zero
    afirmar_igual "$antes" "$(git -C fork.git rev-parse main)"
}
