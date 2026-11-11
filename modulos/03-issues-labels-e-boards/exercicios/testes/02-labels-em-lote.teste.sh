# shellcheck shell=bash
# Testes do exercício 03.02 — Labels em lote (com a cor certa)
montar() {
    printf '# nome\tcor\tdescrição\n' > l.tsv
    printf 'bug\td73a4a\tAlgo não funciona\n\n' >> l.tsv
    printf 'prioridade::alta\t#d93f0b\tResolver nesta semana\n' >> l.tsv
    printf 'primeira contribuição\t7057ff\tBom para começar' >> l.tsv
}
teste_cria_todos() {
    montar; executar l.tsv escola-dev/loja
    afirmar_igual "3" "$(contar_chamadas_glab 'label create*')"
    afirmar_igual "3 labels criados" "$(tail -1 <<<"$SAIDA")"
}
teste_cor_com_cerquilha() {
    montar; executar l.tsv escola-dev/loja
    afirmar_igual "#d73a4a" "$(valor_opcao_glab 'label create --name bug*' --color)" "acrescente # quando faltar"
    afirmar_igual "#d93f0b" "$(valor_opcao_glab 'label create --name prioridade::alta*' --color)" "não duplique o #"
}
teste_nome_com_espaco() {
    montar; executar l.tsv escola-dev/loja
    afirmar_chamou_glab "label create --name 'primeira contribuição' *"
    afirmar_igual "Resolver nesta semana" "$(valor_opcao_glab 'label create --name prioridade::alta*' --description)"
    afirmar_igual "escola-dev/loja" "$(valor_opcao_glab 'label create --name bug*' -R)"
}
teste_arquivo_inexistente() { executar nada.tsv a/b; afirmar_status 1; afirmar_nao_chamou_glab '*'; }
