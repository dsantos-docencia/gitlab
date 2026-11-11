# shellcheck shell=bash
# Testes do Projeto 01 — kit de projeto (glab simulado)
teste_cria_arquivos() {
    executar aluno/laboratorio --sem-api; afirmar_status 0
    for f in .gitlab/issue_templates/Bug.md .gitlab/merge_request_templates/Default.md .gitlab/CODEOWNERS .gitlab-ci.yml; do
        afirmar_arquivo "$f"; afirmar_contem "✔ criado   $f" "$SAIDA"
    done
    afirmar_nao_chamou_glab '*'
}
teste_pipeline_valido() {
    executar aluno/laboratorio --sem-api
    afirmar_schema_gitlab_ci .gitlab-ci.yml
    afirmar_jq .gitlab-ci.yml 'any(.include[]; .template == "Jobs/Secret-Detection.gitlab-ci.yml")'
    afirmar_jq .gitlab-ci.yml 'any(.workflow.rules[]; .when == "never")' "regra anti-duplicação"
}
teste_quick_action_e_secoes() {
    executar aluno/laboratorio --sem-api
    afirmar_contem "/label ~bug" "$(cat .gitlab/issue_templates/Bug.md)"
    afirmar_contem "[Pipeline e segurança][1]" "$(cat .gitlab/CODEOWNERS)"
    afirmar_contem "^[Documentação]" "$(cat .gitlab/CODEOWNERS)" "seção opcional"
}
teste_idempotente() {
    mkdir -p .gitlab && echo "meu" > .gitlab/CODEOWNERS
    executar aluno/laboratorio --sem-api
    afirmar_igual "meu" "$(cat .gitlab/CODEOWNERS)" "não sobrescreve sem --forcar"
    afirmar_contem "• mantido  .gitlab/CODEOWNERS" "$SAIDA"
    executar aluno/laboratorio --sem-api --forcar
    afirmar_contem "[Geral]" "$(cat .gitlab/CODEOWNERS)"
}
teste_api() {
    executar aluno/laboratorio; afirmar_status 0
    afirmar_chamou_glab 'api -X PUT projects/aluno%2Flaboratorio *-F only_allow_merge_if_pipeline_succeeds=true*'
    afirmar_chamou_glab 'api -X PUT*-F only_allow_merge_if_all_discussions_are_resolved=true*'
    afirmar_chamou_glab 'api -X DELETE projects/aluno%2Flaboratorio/protected_branches/main'
    afirmar_chamou_glab 'api -X POST projects/aluno%2Flaboratorio/protected_branches -f name=main -F push_access_level=40 -F merge_access_level=30 -F allow_force_push=false'
    afirmar_chamou_glab "api -X POST projects/aluno%2Flaboratorio/protected_tags -f 'name=v*' -F create_access_level=40"
}
teste_branch_padrao_da_api() {
    simular_glab 'api projects/*' '{"default_branch":"release/2.x"}'
    executar a/b
    afirmar_chamou_glab 'api -X DELETE projects/a%2Fb/protected_branches/release%2F2.x'
    afirmar_chamou_glab 'api -X POST projects/a%2Fb/protected_branches -f name=release/2.x *'
}
teste_pasta() {
    mkdir clone
    executar aluno/laboratorio --pasta clone --sem-api
    afirmar_arquivo clone/.gitlab-ci.yml
}
teste_uso() {
    executar; afirmar_status 2
    executar sem-barra; afirmar_status 2
    executar a/b --pasta nao-existe; afirmar_status 2
}
