# shellcheck shell=bash
# Testes do exercício 03.03 — A fila de triagem
teste_dados_de_exemplo() {
    executar aluno/laboratorio
    afirmar_igual $'#9 Documentar a API de pedidos [documentação, primeira contribuição]\n#10 Botão de login desalinhado no celular [bug]\n#11 Adicionar modo escuro [melhoria]' "$SAIDA"
}
teste_chamada() {
    executar aluno/laboratorio
    afirmar_igual "1" "$(contar_chamadas_glab 'issue list*')"
    afirmar_chamou_glab 'issue list -R aluno/laboratorio *--output json*'
}
teste_usa_iid_e_nao_id() {
    simular_glab 'issue list*' '[{"id":99001,"iid":3,"title":"X","assignees":[],"labels":[]}]'
    executar a/b
    afirmar_igual "#3 X []" "$SAIDA" "exiba o iid (número no projeto), não o id global"
}
teste_vazia() {
    simular_glab 'issue list*' '[{"iid":1,"title":"X","assignees":[{"username":"bia"}],"labels":[]}]'
    executar a/b; afirmar_igual "fila vazia 🎉" "$SAIDA"
}
