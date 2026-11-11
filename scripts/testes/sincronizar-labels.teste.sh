# shellcheck shell=bash
teste_cria_faltantes() {
    executar escola-dev/loja; afirmar_status 0
    afirmar_chamou_glab "api --paginate 'projects/escola-dev%2Floja/labels?per_page=100'"
    afirmar_chamou_glab "api -X POST projects/escola-dev%2Floja/labels -f name=prioridade::alta -f 'color=#b60205' *"
    afirmar_nao_chamou_glab 'api -X POST * -f name=bug *' "bug já existe"
    afirmar_contem "4 criadas, 0 removidas" "$SAIDA" "precisa-triagem + 3 prioridades"
    afirmar_contem "• extra   primeira contribuição" "$SAIDA"
}
teste_remover_simula() {
    executar escola-dev/loja --remover-extras
    afirmar_contem "(simulação) removeria primeira contribuição" "$SAIDA"
    afirmar_nao_chamou_glab 'api -X DELETE *'
}
teste_remover_aplicar() {
    executar escola-dev/loja --remover-extras --aplicar
    afirmar_chamou_glab 'api -X DELETE projects/escola-dev%2Floja/labels/primeira%20contribui%C3%A7%C3%A3o'
}
teste_arquivo() {
    printf '# meu padrão\nbug\t#ff0000\tErro\nurgente\t#000000\tAgora\n' > labels.tsv
    executar a/b --arquivo labels.tsv
    afirmar_chamou_glab 'api -X POST projects/a%2Fb/labels -f name=urgente *'
    afirmar_contem "1 criadas" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; executar a/b --arquivo nada.tsv; afirmar_status 2; }
