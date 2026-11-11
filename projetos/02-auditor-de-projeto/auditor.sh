#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Projeto 02 · Auditor de projeto
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Dá uma nota de 0 a 10 para a "higiene" de um projeto GitLab, só com
#  leituras da API — nada é alterado. Junta os Módulos 02, 06, 07, 10 e 11.
#
#  USO
#    auditor.sh GRUPO/PROJETO [--minimo N] [--json]
#      --minimo N   nota mínima para sair com 0 (padrão: 7) — útil no CI
#      --json       saída em JSON (para guardar e comparar ao longo do tempo)
#
#  ITENS (1 ponto cada)
#    descrição · licença · branch padrão protegida sem force push · tags v*
#    protegidas · merge só com pipeline verde · merge só com discussões
#    resolvidas · no máximo 1 pessoa Maintainer+ · variáveis sensíveis
#    mascaradas e protegidas · nenhum webhook desativado · token do job
#    restrito à allowlist
# ============================================================================
set -euo pipefail

projeto='' minimo=7 json=0
while (( $# )); do
    case "$1" in
        --minimo) minimo="${2:?--minimo precisa de um número}"; shift ;;
        --json)   json=1 ;;
        -h|--help) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)       echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)        projeto="$1" ;;
    esac
    shift
done
[[ "$projeto" =~ ^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)+$ ]] || { echo "uso: $0 GRUPO/PROJETO [--minimo N] [--json]" >&2; exit 2; }
[[ "$minimo" =~ ^[0-9]+$ ]] || { echo "erro: --minimo precisa ser um número" >&2; exit 2; }

enc="$(jq -rn --arg v "$projeto" '$v | @uri')"
# ler LISTA_PADRÃO CAMINHO: GET que, se falhar (404, sem permissão), vira o padrão.
# (a saída de um erro é descartada: o glab imprime o JSON da mensagem de erro.)
ler() { local r; if r="$(glab api "$2" 2>/dev/null)"; then printf '%s' "$r"; else printf '%s' "$1"; fi; }

# Coleta: uma chamada por recurso, guardada para consultar várias vezes.
info="$(glab api "projects/$enc?license=true")"
padrao="$(jq -r '.default_branch // "main"' <<<"$info")"
protecao="$(ler '{}' "projects/$enc/protected_branches/$(jq -rn --arg v "$padrao" '$v | @uri')")"
tags="$(ler '[]' "projects/$enc/protected_tags")"
membros="$(ler '[]' "projects/$enc/members/all?per_page=100")"
variaveis="$(ler '[]' "projects/$enc/variables")"
hooks="$(ler '[]' "projects/$enc/hooks")"
escopo="$(ler '{}' "projects/$enc/job_token_scope")"

# Cada item: chave, descrição e um filtro jq que devolve true/false.
# O jq recebe tudo de uma vez (--argjson) — uma passada, sem estado espalhado.
resultado="$(jq -n \
    --argjson info "$info" --argjson protecao "$protecao" --argjson tags "$tags" \
    --argjson membros "$membros" --argjson variaveis "$variaveis" \
    --argjson hooks "$hooks" --argjson escopo "$escopo" '
  def sensivel: .key | test("TOKEN|SENHA|PASSWORD|SECRET|KEY");
  [
    {item: "descricao",   texto: "descrição preenchida",
     ok: (($info.description // "") | length > 0)},
    {item: "licenca",     texto: "licença definida",
     ok: ($info.license != null)},
    {item: "padrao",      texto: "branch padrão protegida, sem force push",
     ok: ($protecao.name != null and ($protecao.allow_force_push | not))},
    {item: "tags",        texto: "tags v* protegidas",
     ok: any($tags[]; .name == "v*")},
    {item: "pipeline",    texto: "merge só com pipeline verde",
     ok: ($info.only_allow_merge_if_pipeline_succeeds == true)},
    {item: "discussoes",  texto: "merge só com discussões resolvidas",
     ok: ($info.only_allow_merge_if_all_discussions_are_resolved == true)},
    {item: "maintainers", texto: "no máximo 1 pessoa Maintainer ou acima",
     ok: ([$membros[] | select(.access_level >= 40)] | length <= 1),
     detalhe: ([$membros[] | select(.access_level >= 40) | .username] | join(", "))},
    {item: "variaveis",   texto: "variáveis sensíveis mascaradas e protegidas",
     ok: (all($variaveis[] | select(sensivel); .masked and .protected)),
     detalhe: ([$variaveis[] | select(sensivel and ((.masked and .protected) | not)) | .key] | join(", "))},
    {item: "webhooks",    texto: "nenhum webhook desativado",
     ok: (all($hooks[]; .alert_status != "disabled"))},
    {item: "job_token",   texto: "token do job restrito à allowlist",
     ok: ($escopo.inbound_enabled == true)}
  ] | {projeto: $info.path_with_namespace, itens: ., nota: (map(select(.ok)) | length), total: length}')"

nota="$(jq .nota <<<"$resultado")"
if (( json )); then
    jq --arg q "$(date -u +%FT%TZ)" '. + {quando: $q}' <<<"$resultado"
else
    echo "Auditoria de $projeto"
    jq -r '.itens[] | "  \(if .ok then "✔" else "✘" end) \(.texto)" +
           (if (.ok | not) and (.detalhe // "") != "" then " (\(.detalhe))" else "" end)' <<<"$resultado"
    echo "nota: $nota/$(jq .total <<<"$resultado")"
fi
(( nota >= minimo ))
