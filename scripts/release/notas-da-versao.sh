#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/release/notas-da-versao.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Notas de versão a partir dos commits entre duas tags (Conventional Commits),
#  pela API de comparação — para revisar antes de publicar a release.
#  (Para changelog por trailers "Changelog:", veja o Módulo 09.)
#
#  USO
#    notas-da-versao.sh GRUPO/PROJETO DE PARA [--saida ARQ.md]
#      ex.: notas-da-versao.sh escola-dev/loja v1.1.0 v1.2.0 --saida NOTAS.md
# ============================================================================
set -euo pipefail

args=() saida=''
while (( $# )); do
    case "$1" in
        --saida)   saida="${2:?--saida precisa de um arquivo}"; shift ;;
        -h|--help) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)        echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)         args+=("$1") ;;
    esac
    shift
done
(( ${#args[@]} == 3 )) && [[ "${args[0]}" == */* ]] || { echo "uso: $0 GRUPO/PROJETO DE PARA [--saida ARQ.md]" >&2; exit 2; }
projeto="${args[0]}" de="${args[1]}" para="${args[2]}"

enc="$(jq -rn --arg v "$projeto" '$v | @uri')"
q() { jq -rn --arg v "$1" '$v | @uri'; }
comparacao="$(glab api "projects/$enc/repository/compare?from=$(q "$de")&to=$(q "$para")")"

notas="$(jq -r --arg de "$de" --arg para "$para" '
  def tipo: if test("^[a-z]+(\\([^)]*\\))?!:") or test("BREAKING CHANGE") then "quebra"
            elif test("^feat(\\(|:)") then "feat" elif test("^fix(\\(|:)") then "fix"
            elif test("^docs(\\(|:)") then "docs" else "outros" end;
  def limpa: sub("^[a-z]+(\\([^)]*\\))?!?: "; "");
  [.commits[] | select(.title | test("^Merge (branch|remote-tracking)") | not)
              | {t: (.title | tipo), texto: "- \(.title | limpa) (\(.short_id), \(.author_name))"}] as $cs
  | [["quebra", "⚠️ Mudanças incompatíveis"], ["feat", "✨ Novidades"], ["fix", "🐛 Correções"],
     ["docs", "📝 Documentação"], ["outros", "🔧 Outros"]] as $secoes
  | "## \($para)\n\n_Mudanças desde \($de) · \($cs | length) commits_\n" +
    ([$secoes[] | . as [$k, $titulo] | [$cs[] | select(.t == $k) | .texto] as $itens
      | select($itens | length > 0) | "\n### \($titulo)\n\n" + ($itens | join("\n")) + "\n"] | join(""))
' <<<"$comparacao")"

if [[ -n "$saida" ]]; then
    printf '%s\n' "$notas" > "$saida"; echo "notas gravadas em $saida — revise antes de publicar"
else
    printf '%s\n' "$notas"
fi
