# shellcheck shell=bash
# Testes do exercício 01.01 — E-mail privado nos commits
teste_email() {
    executar 1234567 ana-dev
    afirmar_igual "1234567-ana-dev@users.noreply.gitlab.com" "$(git -C projeto config --local user.email)"
}
teste_nome() { executar 1 bia; afirmar_igual "bia" "$(git -C projeto config --local user.name)"; }
teste_commit_usa_o_email() {
    executar 42 caio
    unset GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL GIT_AUTHOR_NAME GIT_COMMITTER_NAME
    commitar a.txt x "teste" projeto
    afirmar_igual "42-caio@users.noreply.gitlab.com" "$(git -C projeto log -1 --format=%ae)"
}
teste_uso() { executar; afirmar_status 2; }
teste_id_invalido() {
    executar abc ana; afirmar_status 1
    [[ -e projeto ]] && _falhar "com ID inválido nada deve ser criado"; return 0
}
