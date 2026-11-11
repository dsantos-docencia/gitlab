#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 03.02 — Labels em lote (com a cor certa) · SOLUÇÃO COMENTADA
set -euo pipefail

arquivo="${1:?uso: $0 <labels.tsv> <grupo/projeto>}"
projeto="${2:?uso: $0 <labels.tsv> <grupo/projeto>}"
[[ -f "$arquivo" ]] || { echo "erro: arquivo não encontrado: $arquivo" >&2; exit 1; }
n=0
while IFS=$'\t' read -r nome cor descricao || [[ -n "$nome" ]]; do
    [[ -z "$nome" || "$nome" == \#* ]] && continue
    # ${cor#\#} tira um # se houver; depois colocamos exatamente um.
    cor="#${cor#\#}"
    glab label create --name "$nome" --color "$cor" --description "$descricao" -R "$projeto"
    n=$((n + 1))
done < "$arquivo"
echo "$n labels criados"
