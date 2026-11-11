# shellcheck shell=bash
# Testes do exercício 02.01 — Criar grupo e projeto
teste_cria_grupo() {
    executar "Escola Dev" escola-dev loja
    afirmar_status 0
    afirmar_chamou_glab "api -X POST groups *"
    afirmar_igual "name=Escola Dev" "$(valor_opcao_glab 'api -X POST groups*' -f)" "o 1º -f deve ser name= (com o nome inteiro, espaço incluído)"
    afirmar_chamou_glab "api -X POST groups *-f path=escola-dev*"
    afirmar_chamou_glab "api -X POST groups *-f visibility=private*"
}
teste_cria_projeto() {
    executar "Escola Dev" escola-dev loja
    afirmar_chamou_glab 'repo create loja --group escola-dev --private --defaultBranch main'
}
teste_caminho_invalido() {
    executar "Escola Dev" "Escola Dev" loja
    afirmar_status 2
    afirmar_nao_chamou_glab '*'
}
teste_faltando() { executar "Escola Dev" escola-dev; afirmar_status 2; }
