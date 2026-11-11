# shellcheck shell=bash
# Testes do exercício 04.03 — MR criado pelo git push
montar() {
    git init -q --bare servidor.git
    git -C servidor.git config receive.advertisePushOptions true
    printf '#!/usr/bin/env bash\nfor ((i=0;i<${GIT_PUSH_OPTION_COUNT:-0};i++)); do v="GIT_PUSH_OPTION_$i"; printf "%%s\\n" "${!v}"; done >> "%s/opcoes.txt"\n' "$PWD" > servidor.git/hooks/pre-receive
    chmod +x servidor.git/hooks/pre-receive
    git clone -q servidor.git app 2>/dev/null
    commitar a.txt base "feat: base" app; git -C app push -q origin main; : > opcoes.txt
    git -C app switch -q -c feature/frete
    commitar f.txt 1 "feat: calcula frete" app
    commitar f.txt 2 "feat: frete grátis acima de R\$ 200" app
}
teste_publica_com_upstream() {
    montar; executar 12
    afirmar_status 0
    afirmar_igual "$(git -C app rev-parse HEAD)" "$(git -C servidor.git rev-parse feature/frete 2>/dev/null)"
    afirmar_igual "origin/feature/frete" "$(git -C app rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)" "use git push -u"
}
teste_opcoes() {
    montar; executar 12
    local o; o="$(cat opcoes.txt)"
    afirmar_contem "merge_request.create" "$o"
    afirmar_contem "merge_request.target=main" "$o"
    afirmar_contem 'merge_request.title=feat: frete grátis acima de R$ 200' "$o" "título = assunto do último commit"
    afirmar_contem "merge_request.description=Closes #12" "$o"
    afirmar_contem "merge_request.remove_source_branch" "$o"
}
teste_um_push_so() {
    montar; executar 7
    afirmar_igual "5" "$(grep -c . opcoes.txt)" "um único push com as 5 opções"
}
teste_sem_issue() {
    montar; executar
    afirmar_status 2
    git -C servidor.git rev-parse -q --verify feature/frete >/dev/null && _falhar "não publique nada sem issue válido"; return 0
}
