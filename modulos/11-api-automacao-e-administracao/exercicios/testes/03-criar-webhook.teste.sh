# shellcheck shell=bash
# Testes do exercício 11.03 — Criar webhook sem duplicar
export WEBHOOK_SEGREDO=s3gr3d0
teste_cria() {
    executar escola-dev/loja https://exemplo.dev/webhook; afirmar_status 0
    afirmar_chamou_glab 'api projects/escola-dev%2Floja/hooks'
    afirmar_chamou_glab 'api -X POST projects/escola-dev%2Floja/hooks *'
    afirmar_igual "https://exemplo.dev/webhook" "$(valor_opcao_glab 'api -X POST*' -f | head -1 | sed 's/^url=//')" "-f url=..."
    afirmar_chamou_glab 'api -X POST*-f token=s3gr3d0*' "o segredo vai no -f token="
    afirmar_chamou_glab 'api -X POST*-F merge_requests_events=true*'
    afirmar_chamou_glab 'api -X POST*-F pipeline_events=true*'
    afirmar_chamou_glab 'api -X POST*-F push_events=false*'
    afirmar_chamou_glab 'api -X POST*-F enable_ssl_verification=true*'
}
teste_ja_existe() {
    executar escola-dev/loja https://chat.exemplo.dev/gitlab; afirmar_status 0
    afirmar_contem "já existe" "$SAIDA"
    afirmar_nao_chamou_glab 'api -X POST*'
}
teste_desativado() {
    executar escola-dev/loja https://exemplo.dev/webhook
    afirmar_contem "ATENÇÃO webhook 29 desativado: http://antigo.exemplo.dev/hook" "$ERRO"
}
teste_uso() {
    executar a/b; afirmar_status 2
    executar a/b http://inseguro.dev; afirmar_status 2 "só https://"
    WEBHOOK_SEGREDO='' executar a/b https://x.dev; afirmar_status 2
    afirmar_nao_chamou_glab 'api -X POST*'
}
