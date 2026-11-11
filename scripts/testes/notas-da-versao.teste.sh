# shellcheck shell=bash
teste_secoes() {
    executar escola-dev/loja v1.1.0 v1.2.0; afirmar_status 0
    afirmar_chamou_glab "api 'projects/escola-dev%2Floja/repository/compare?from=v1.1.0&to=v1.2.0'"
    afirmar_contem "## v1.2.0" "$SAIDA"
    afirmar_contem "_Mudanças desde v1.1.0 · 5 commits_" "$SAIDA" "o merge commit não conta"
    afirmar_contem "### ⚠️ Mudanças incompatíveis" "$SAIDA"
    afirmar_contem "- remove a API v1 de pedidos (c4d5e6f, Bia Dev)" "$SAIDA"
    afirmar_contem "- exportação CSV (f1a2b3c, Bia Dev)" "$SAIDA" "o escopo (pedidos) sai do texto"
    afirmar_contem "### 🐛 Correções" "$SAIDA"
    afirmar_contem "- ajustes (a6f7a8b, Ex Estagiário)" "$SAIDA"
    afirmar_nao_contem "Merge branch" "$SAIDA"
}
teste_ordem() {
    executar a/b v1 v2
    afirmar_igual "⚠️ ✨ 🐛 📝 🔧" "$(grep '^### ' <<<"$SAIDA" | awk '{print $2}' | xargs)"
}
teste_secao_vazia_some() {
    simular_glab 'api projects/*' '{"commits":[{"short_id":"1","title":"fix: um","author_name":"x"}]}'
    executar a/b v1 v2
    afirmar_contem "### 🐛 Correções" "$SAIDA"; afirmar_nao_contem "### ✨" "$SAIDA"
}
teste_arquivo() {
    executar a/b v1 v2 --saida NOTAS.md
    afirmar_arquivo NOTAS.md; afirmar_contem "## v2" "$(cat NOTAS.md)"
}
teste_uso() { executar a/b v1; afirmar_status 2; executar; afirmar_status 2; }
