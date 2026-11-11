# shellcheck shell=bash
# Testes do exercício 04.01 — CODEOWNERS com seções
linhas() { grep -vE '^\s*(#|$)' .gitlab/CODEOWNERS | awk '{$1=$1; print}'; }
teste_local() { executar; afirmar_arquivo .gitlab/CODEOWNERS "o GitLab procura em CODEOWNERS, docs/CODEOWNERS ou .gitlab/CODEOWNERS"; }
teste_regra_geral_primeiro() { executar; afirmar_igual "* @aluno" "$(linhas | head -1)"; }
teste_frontend() {
    executar
    afirmar_contem $'[Frontend] @bia-dev\n*.js\n*.css' "$(linhas)" \
        "a seção [Frontend] @bia-dev seguida de *.js e *.css (linhas sem dono herdam o padrão da seção)"
}
teste_documentacao() {
    executar
    afirmar_contem $'[Documentação]\n/docs/ @escola-dev/docs' "$(linhas)"
}
teste_opcional() {
    executar
    afirmar_contem $'^[Opcional]\n*.md @caio-qa' "$(linhas)" "seção opcional começa com ^"
}
