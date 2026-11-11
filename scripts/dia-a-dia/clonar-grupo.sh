#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · scripts/dia-a-dia/clonar-grupo.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Clona todos os projetos de um grupo (com subgrupos), mantendo a hierarquia
#  de pastas — ou atualiza com pull --ff-only os que já existem. Arquivados
#  ficam de fora, a não ser que você peça.
#
#  USO
#    clonar-grupo.sh GRUPO [DESTINO] [--arquivados] [--https] [--simular]
#      DESTINO       pasta-raiz (padrão: .) → DESTINO/grupo/subgrupo/projeto
#      --arquivados  inclui projetos arquivados
#      --https       clona por HTTPS em vez de SSH
#      --simular     só mostra o que faria
# ============================================================================
set -euo pipefail

grupo='' destino='.' arquivados=0 campo=ssh_url_to_repo simular=0
while (( $# )); do
    case "$1" in
        --arquivados) arquivados=1 ;;
        --https)      campo=http_url_to_repo ;;
        --simular)    simular=1 ;;
        -h|--help)    sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)           echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)            if [[ -z "$grupo" ]]; then grupo="$1"; else destino="$1"; fi ;;
    esac
    shift
done
[[ -n "$grupo" ]] || { echo "uso: $0 GRUPO [DESTINO] [--arquivados] [--https] [--simular]" >&2; exit 2; }

enc="$(jq -rn --arg v "$grupo" '$v | @uri')"
clonados=0 atualizados=0 pulados=0 falhas=0
# Process substitution (< <(...)) em vez de pipe: os contadores ficam neste shell.
while IFS=$'\t' read -r caminho url arquivado; do
    if [[ "$arquivado" == true && "$arquivados" == 0 ]]; then
        (( ++pulados )); continue
    fi
    pasta="$destino/$caminho"
    if [[ -d "$pasta/.git" ]]; then
        if (( simular )); then echo "atualizaria $caminho"; (( ++atualizados )); continue; fi
        if git -C "$pasta" pull -q --ff-only; then echo "  ↻ $caminho"; (( ++atualizados ))
        else echo "  ✘ $caminho: pull --ff-only falhou (alterações locais?)" >&2; (( ++falhas )); fi
    else
        if (( simular )); then echo "clonaria $caminho  ←  $url"; (( ++clonados )); continue; fi
        mkdir -p -- "$(dirname -- "$pasta")"
        if git clone -q -- "$url" "$pasta"; then echo "  ✔ $caminho"; (( ++clonados ))
        else echo "  ✘ $caminho: clone falhou" >&2; (( ++falhas )); fi
    fi
done < <(glab api --paginate "groups/$enc/projects?include_subgroups=true&per_page=100" |
         jq -r --arg c "$campo" 'sort_by(.path_with_namespace)[] | [.path_with_namespace, .[$c], (.archived | tostring)] | @tsv')

echo "$clonados clonados, $atualizados atualizados, $pulados arquivados pulados, $falhas falhas"
(( falhas == 0 ))
