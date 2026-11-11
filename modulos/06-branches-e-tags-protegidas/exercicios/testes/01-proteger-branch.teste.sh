# shellcheck shell=bash
# Testes do exercício 06.01 — Proteger a main (idempotente)
teste_ja_protegida_deleta_e_recria() {
    executar escola-dev/loja
    afirmar_status 0
    afirmar_chamou_glab 'api -X DELETE projects/escola-dev%2Floja/protected_branches/main'
    afirmar_chamou_glab 'api -X POST projects/escola-dev%2Floja/protected_branches -f name=main *'
    afirmar_igual "main protegida em escola-dev/loja" "$SAIDA"
}
teste_niveis() {
    executar escola-dev/loja
    afirmar_chamou_glab 'api -X POST*-F push_access_level=0*' "push: ninguém (0)"
    afirmar_chamou_glab 'api -X POST*-F merge_access_level=30*' "merge: Developers+ (30)"
    afirmar_chamou_glab 'api -X POST*-F allow_force_push=false*'
}
teste_nao_protegida_so_cria() {
    simular_glab 'api projects/*/protected_branches/main' '{"message":"404 Not found"}' 1
    executar escola-dev/loja
    afirmar_nao_chamou_glab 'api -X DELETE*' "se não está protegida, não há o que apagar"
    afirmar_chamou_glab 'api -X POST*'
}
teste_ordem() {
    executar a/b
    local ordem; ordem="$(chamadas_glab | grep -oE 'X (DELETE|POST)' | tr '\n' ' ')"
    afirmar_igual "X DELETE X POST " "$ordem" "primeiro DELETE, depois POST"
}
teste_uso() { executar loja; afirmar_status 2; }
