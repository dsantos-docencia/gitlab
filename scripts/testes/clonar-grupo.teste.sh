# shellcheck shell=bash
# Servidor local: dois repositórios "remotos" e um JSON de grupo apontando para eles.
servidor() {
    local r
    for r in loja api legado; do
        git init -q --bare "srv/$r.git"; git clone -q "srv/$r.git" "tmp-$r" 2>/dev/null
        commitar README.md "# $r" "c1" "tmp-$r"; git -C "tmp-$r" push -q origin main
    done
    simular_glab 'api --paginate groups/*' "[
      {\"path_with_namespace\":\"escola-dev/loja\",\"archived\":false,\"ssh_url_to_repo\":\"$PWD/srv/loja.git\",\"http_url_to_repo\":\"https://x/loja.git\"},
      {\"path_with_namespace\":\"escola-dev/backend/api\",\"archived\":false,\"ssh_url_to_repo\":\"$PWD/srv/api.git\"},
      {\"path_with_namespace\":\"escola-dev/legado\",\"archived\":true,\"ssh_url_to_repo\":\"$PWD/srv/legado.git\"}]"
}
teste_clona_com_hierarquia() {
    servidor
    executar escola-dev codigo; afirmar_status 0
    afirmar_chamou_glab "api --paginate 'groups/escola-dev/projects?include_subgroups=true&per_page=100'"
    afirmar_arquivo codigo/escola-dev/loja/README.md
    afirmar_arquivo codigo/escola-dev/backend/api/README.md "subgrupo vira subpasta"
    afirmar_contem "2 clonados, 0 atualizados, 1 arquivados pulados" "$SAIDA"
    [[ ! -e codigo/escola-dev/legado ]] || _falhar "arquivado não deveria ser clonado"
}
teste_atualiza() {
    servidor
    executar escola-dev codigo
    commitar novo.txt 2 "c2" tmp-loja; git -C tmp-loja push -q origin main
    executar escola-dev codigo
    afirmar_contem "0 clonados, 2 atualizados" "$SAIDA"
    afirmar_arquivo codigo/escola-dev/loja/novo.txt "deveria ter feito pull"
}
teste_arquivados_e_simular() {
    servidor
    executar escola-dev codigo --arquivados --simular
    afirmar_contem "clonaria escola-dev/legado" "$SAIDA"
    [[ ! -e codigo ]] || _falhar "--simular não cria nada"
}
teste_https() {
    servidor
    executar escola-dev codigo --https --simular
    afirmar_contem "clonaria escola-dev/loja  ←  https://x/loja.git" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; }
