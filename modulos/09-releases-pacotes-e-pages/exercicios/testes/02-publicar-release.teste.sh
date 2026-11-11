# shellcheck shell=bash
# Testes do exercício 09.02 — Script de publicação com changelog
teste_publica() {
    executar 1.2.0; afirmar_status 0
    afirmar_chamou_glab 'api projects/aluno%2Flaboratorio/releases'
    afirmar_chamou_glab "api 'projects/aluno%2Flaboratorio/repository/changelog?version=1.2.0'" "(o ? exige aspas na URL)"
    afirmar_chamou_glab 'release create v1.2.0 *--ref main*-R aluno/laboratorio*'
    afirmar_contem "Exportação CSV" "$(valor_opcao_glab 'release create*' --notes)" "as notas vêm do changelog"
}
teste_outro_projeto() {
    PROJETO=escola-dev/loja executar 2.0.0; afirmar_status 0
    afirmar_chamou_glab 'api projects/escola-dev%2Floja/releases'
    afirmar_chamou_glab 'release create v2.0.0 *-R escola-dev/loja*'
}
teste_ja_existe() {
    executar 1.1.0; afirmar_status 1 "v1.1.0 já existe na lista: saída 1"
    afirmar_nao_chamou_glab 'release create*'
}
teste_versao_invalida() {
    executar 1.2; afirmar_status 2
    executar v1.2.0; afirmar_status 2 "a versão é sem o v"
    executar; afirmar_status 2
    afirmar_nao_chamou_glab 'release create*'
}
