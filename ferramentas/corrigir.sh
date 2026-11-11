#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLabHub — Colaboração, Automação e Segurança
#  ferramentas/corrigir.sh — Corretor automático de exercícios
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/gitlab
#  © 2026 Daniel Santos — Código sob PolyForm Noncommercial 1.0.0 (veja LICENSE)
# ============================================================================
#
#  USO
#    ./ferramentas/corrigir.sh 04 02          # corrige o exercício 02 do módulo 04
#    ./ferramentas/corrigir.sh 04             # corrige todos os exercícios do módulo 04
#    ./ferramentas/corrigir.sh --todos        # corrige tudo
#    ./ferramentas/corrigir.sh 04 02 --solucao   # roda os testes contra a solução oficial
#
#  O QUE ELE FAZ
#    1. Localiza o exercício (modulos/04-*/exercicios/02-*.sh)
#    2. Localiza o teste    (modulos/04-*/exercicios/testes/02-*.teste.sh)
#    3. Roda cada caso de teste num diretório temporário isolado
#    4. Mostra ✔/✘ com a explicação de cada falha
# ============================================================================
set -uo pipefail
# Não usamos `set -e` aqui de propósito: o corretor PRECISA continuar
# rodando quando um teste falha. (Discussão completa no Módulo 08.)

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/teste.sh
source "$RAIZ/ferramentas/lib/teste.sh"

uso() {
    sed -n '/^#  USO/,/^#  O QUE/p' "${BASH_SOURCE[0]}" | sed '$d; s/^#  \{0,1\}//'
    exit "${1:-0}"
}

usar_solucao=0
args=()
for a in "$@"; do
    case "$a" in
        --solucao|--solução) usar_solucao=1 ;;
        -h|--help|--ajuda)   uso 0 ;;
        --todos)             args+=("*") ;;
        *)                   args+=("$a") ;;
    esac
done
(( ${#args[@]} >= 1 )) || uso 1

# Aceita "4" ou "04"; printf -v formata direto numa variável, sem subshell.
normalizar() { [[ "$1" == "*" ]] && { printf '*'; return; }; printf '%02d' "$((10#$1))"; }

mod="$(normalizar "${args[0]}")"
exe="$(normalizar "${args[1]:-*}")"

shopt -s nullglob   # glob sem resultado vira lista vazia, não o texto literal
# shellcheck disable=SC2206  # a expansão do glob é justamente o que queremos
testes=( "$RAIZ"/modulos/${mod}-*/exercicios/testes/${exe}-*.teste.sh )

if (( ${#testes[@]} == 0 )); then
    printf 'Nenhum exercício encontrado para módulo %s, exercício %s.\n' "$mod" "$exe" >&2
    exit 2
fi

falhas=0
for t in "${testes[@]}"; do
    dir_ex="$(dirname -- "$(dirname -- "$t")")"
    base="$(basename -- "$t" .teste.sh)"
    if (( usar_solucao )); then
        alvo="$dir_ex/solucoes/$base.sh"
    else
        alvo="$dir_ex/$base.sh"
    fi
    modulo_nome="$(basename -- "$(dirname -- "$dir_ex")")"

    printf '\n%s▶ %s · %s%s%s\n' "$_NEGRITO" "$modulo_nome" "$base" \
        "$( (( usar_solucao )) && printf ' (solução oficial)')" "$_RESET"

    if [[ ! -f "$alvo" ]]; then
        printf '    %s✘ arquivo não encontrado: %s%s\n' "$_VERMELHO" "${alvo#"$RAIZ"/}" "$_RESET"
        (( falhas++ )); continue
    fi
    if ! bash -n "$alvo" 2>/dev/null; then
        printf '    %s✘ erro de sintaxe — rode: bash -n %s%s\n' "$_VERMELHO" "${alvo#"$RAIZ"/}" "$_RESET"
        (( falhas++ )); continue
    fi

    # Subshell: as funções teste_* de um exercício não contaminam o próximo.
    ( rodar_testes "$t" "$alvo" ) || (( falhas++ ))
done

echo
if (( falhas == 0 )); then
    printf '%s%sTudo certo!%s\n' "$_NEGRITO" "$_VERDE" "$_RESET"
else
    printf '%s%s%d exercício(s) com pendências.%s\n' "$_NEGRITO" "$_AMARELO" "$falhas" "$_RESET"
fi
exit $(( falhas > 0 ))
