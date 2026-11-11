# shellcheck shell=bash
# Testes do laboratorio/criar-lab.sh (modo --simular: nada sai da máquina)
teste_cria_projeto_privado() {
    executar --simular; afirmar_status 0
    afirmar_chamou_glab 'api -X POST projects -f name=lab-gitlab -f path=lab-gitlab -f visibility=private -f default_branch=main -F initialize_with_readme=false *'
    afirmar_contem "(simulado) git push" "$SAIDA"
}
teste_publico_e_nome() {
    executar --simular --publico --nome meu-lab
    afirmar_chamou_glab 'api -X POST projects -f name=meu-lab -f path=meu-lab -f visibility=public *'
    afirmar_contem "LAB_PROJETO=aluno/meu-lab" "$SAIDA"
}
teste_labels_e_issues() {
    executar --simular
    afirmar_igual "5" "$(contar_chamadas_glab 'label create*')" "5 labels"
    afirmar_igual "4" "$(contar_chamadas_glab 'issue create*')" "4 issues de exemplo"
    afirmar_chamou_glab "label create -R aluno/lab-gitlab --name prioridade::alta --color '#b60205' *"
    afirmar_chamou_glab "issue create -R aluno/lab-gitlab --title 'Documentar a API de pedidos' *--label 'documentação,primeira contribuição' --yes"
}
teste_opcao_invalida() { executar --xyz; afirmar_status 2; executar --simular --nome 'a b'; afirmar_status 2; }
