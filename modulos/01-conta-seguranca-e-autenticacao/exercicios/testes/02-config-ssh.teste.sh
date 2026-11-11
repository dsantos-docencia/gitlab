# shellcheck shell=bash
# Testes do exercício 01.02 — Config SSH com a porta 443
opcao() {
    awk -v h="$1" -v o="$2" '
        tolower($1)=="host" { dentro = ($2 == h); next }
        dentro && tolower($1)==tolower(o) { $1=""; sub(/^ /,""); print; exit }' ssh/config
}
teste_bloco_principal() {
    executar; afirmar_arquivo ssh/config
    afirmar_igual "gitlab.com" "$(opcao gitlab.com HostName)"
    afirmar_igual "git" "$(opcao gitlab.com User)"
    # shellcheck disable=SC2088  # o ~ deve ficar LITERAL
    afirmar_igual "~/.ssh/id_ed25519_gitlab" "$(opcao gitlab.com IdentityFile)"
    afirmar_igual "yes" "$(opcao gitlab.com IdentitiesOnly)"
}
teste_bloco_443() {
    executar
    afirmar_igual "altssh.gitlab.com" "$(opcao gitlab-443 HostName)" "no GitLab.com, a porta 443 fica em altssh.gitlab.com"
    afirmar_igual "443" "$(opcao gitlab-443 Port)"
}
teste_permissao() {
    executar; afirmar_igual "600" "$(stat -c %a ssh/config 2>/dev/null || stat -f %Lp ssh/config)"
}
