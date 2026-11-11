#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLabHub — Colaboração, Automação e Segurança
#  ferramentas/lib/teste.sh — Mini framework de testes em Bash puro
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/gitlab
#  © 2026 Daniel Santos — Código sob PolyForm Noncommercial 1.0.0 (veja LICENSE)
# ============================================================================
#
#  POR QUE UM FRAMEWORK PRÓPRIO?
#  ----------------------------------------------------------------------------
#  O padrão de mercado para testar Bash é o Bats (bats-core) — visto no curso
#  de Bash. Mas exigir uma ferramenta extra logo na primeira aula cria atrito.
#  Este arquivo tem ~250 linhas, depende só de bash, git, jq e python3, e é ele
#  mesmo material de estudo. Além das asserções de texto, ele sabe verificar
#  YAML/JSON (afirmar_jq), pipelines (afirmar_schema_gitlab_ci) e as chamadas
#  feitas ao glab simulado (afirmar_chamou_glab — veja glab-simulado.sh).
#
#  COMO UM ARQUIVO DE TESTE É ESCRITO
#  ----------------------------------------------------------------------------
#    teste_saudacao_padrao() {
#        executar                      # roda o script do aluno sem argumentos
#        afirmar_status 0
#        afirmar_igual "Olá, mundo!" "$SAIDA"
#    }
#
#  Toda função cujo nome começa com "teste_" é descoberta e executada,
#  cada uma num subshell isolado e num diretório temporário próprio.
#
#  VARIÁVEIS DISPONÍVEIS DENTRO DE UM TESTE
#    ALVO    caminho absoluto do script sendo testado
#    SAIDA   stdout da última chamada a executar (sem a quebra de linha final)
#    ERRO    stderr da última chamada a executar
#    STATUS  código de saída da última chamada a executar
# ============================================================================

# Cores só quando a saída é um terminal (em CI ou redirecionado, texto puro).
if [[ -t 1 ]]; then
    _VERDE=$'\e[32m' _VERMELHO=$'\e[31m' _AMARELO=$'\e[33m'
    _NEGRITO=$'\e[1m' _APAGADO=$'\e[2m' _RESET=$'\e[0m'
else
    _VERDE='' _VERMELHO='' _AMARELO='' _NEGRITO='' _APAGADO='' _RESET=''
fi

# Ambiente Git isolado e previsível (identidade fixa, branch inicial main).
# shellcheck source=git-sandbox.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/git-sandbox.sh"
# glab simulado na frente do PATH + asserções sobre as chamadas (afirmar_chamou_glab…).
# shellcheck source=glab-simulado.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/glab-simulado.sh"
_LIB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Tempo máximo (segundos) de cada execução do script do aluno.
# Protege contra laços infinitos — erro comum e honesto de quem está aprendendo.
TEMPO_LIMITE="${TEMPO_LIMITE:-10}"

# shellcheck disable=SC2034  # usados pelos arquivos de teste que fazem source desta lib
SAIDA='' ERRO='' STATUS=0

# ----------------------------------------------------------------------------
# executar [args...]
#   Roda "$ALVO" com os argumentos dados, stdin vazio (/dev/null).
# ----------------------------------------------------------------------------
executar() {
    executar_com_entrada '' "$@"
}

# ----------------------------------------------------------------------------
# executar_com_entrada "texto para stdin" [args...]
#   Igual a executar, mas alimenta o stdin do script com o texto informado.
#   Útil para testar scripts que usam `read`.
# ----------------------------------------------------------------------------
executar_com_entrada() {
    local entrada="$1"; shift
    local arq_out arq_err
    arq_out="$(mktemp)" arq_err="$(mktemp)"

    # `timeout` mata o processo se passar do limite; status 124 = estourou.
    timeout "$TEMPO_LIMITE" bash "$ALVO" "$@" \
        < <(printf '%s' "$entrada") >"$arq_out" 2>"$arq_err"
    STATUS=$?

    # $(< arquivo) lê o arquivo sem criar processo extra e remove as \n finais.
    # SAIDA/ERRO são lidos pelos arquivos de teste que dão source nesta lib.
    # shellcheck disable=SC2034
    SAIDA="$(< "$arq_out")"
    # shellcheck disable=SC2034
    ERRO="$(< "$arq_err")"
    rm -f -- "$arq_out" "$arq_err"

    if (( STATUS == 124 )); then
        _falhar "o script passou de ${TEMPO_LIMITE}s (laço infinito? read esperando teclado?)"
    fi
    return 0
}

# ----------------------------------------------------------------------------
# Asserções — cada uma encerra o teste com falha e uma explicação didática.
# ----------------------------------------------------------------------------
afirmar_igual() {           # afirmar_igual ESPERADO OBTIDO [mensagem]
    [[ "$1" == "$2" ]] && return 0
    _falhar "${3:-valores diferentes}" \
            "esperado: «$1»" \
            "obtido:   «$2»"
}

afirmar_contem() {          # afirmar_contem TRECHO TEXTO [mensagem]
    [[ "$2" == *"$1"* ]] && return 0
    _falhar "${3:-trecho não encontrado}" \
            "procurado: «$1»" \
            "no texto:  «$2»"
}

afirmar_nao_contem() {      # afirmar_nao_contem TRECHO TEXTO [mensagem]
    [[ "$2" != *"$1"* ]] && return 0
    _falhar "${3:-trecho não deveria aparecer}" "trecho: «$1»"
}

afirmar_casa() {            # afirmar_casa REGEX TEXTO [mensagem]
    [[ "$2" =~ $1 ]] && return 0
    _falhar "${3:-texto não casa com o padrão}" \
            "regex: $1" "texto: «$2»"
}

afirmar_status() {          # afirmar_status CODIGO [mensagem]
    (( STATUS == $1 )) && return 0
    _falhar "${2:-código de saída inesperado}" \
            "esperado: $1" "obtido:   $STATUS" \
            "stderr:   «$ERRO»"
}

afirmar_status_diferente_de_zero() {
    (( STATUS != 0 )) && return 0
    _falhar "${1:-o script deveria falhar (status ≠ 0), mas terminou com 0}"
}

afirmar_arquivo() {         # afirmar_arquivo CAMINHO [mensagem]
    [[ -f "$1" ]] && return 0
    _falhar "${2:-arquivo não existe}" "caminho: $1"
}

afirmar_diretorio() {       # afirmar_diretorio CAMINHO [mensagem]
    [[ -d "$1" ]] && return 0
    _falhar "${2:-diretório não existe}" "caminho: $1"
}

# ----------------------------------------------------------------------------
# Arquivos de configuração (YAML/JSON) — o coração de muitos exercícios de
# GitHub: workflows, issue forms, dependabot.yml, rulesets…
# ----------------------------------------------------------------------------
json_de() {                 # json_de ARQUIVO  → JSON na saída (YAML é convertido)
    case "$1" in
        *.yml|*.yaml) python3 "$_LIB_DIR/yaml2json.py" "$1" ;;
        *)            cat -- "$1" ;;
    esac
}

valor_jq() {                # valor_jq ARQUIVO FILTRO  → resultado (texto cru)
    json_de "$1" | jq -r "$2"
}

afirmar_jq() {              # afirmar_jq ARQUIVO FILTRO [mensagem]
    [[ -f "$1" ]] || _falhar "arquivo não existe: $1"
    local json
    json="$(json_de "$1" 2>&1)" || _falhar "não consegui ler $1" "$json"
    jq -e "$2" >/dev/null 2>&1 <<<"$json" && return 0
    _falhar "${3:-a condição não vale em $1}" "filtro jq: $2"
}

afirmar_schema_gitlab_ci() {  # afirmar_schema_gitlab_ci ARQUIVO — valida contra o schema oficial do .gitlab-ci.yml
    command -v check-jsonschema >/dev/null || return 0   # opcional fora do CI
    local saida
    saida="$(check-jsonschema --builtin-schema vendor.gitlab-ci "$1" 2>&1)" && return 0
    _falhar "o pipeline não passa no schema oficial do GitLab CI" "$saida"
}

# ----------------------------------------------------------------------------
# Internos
# ----------------------------------------------------------------------------
_falhar() {
    local linha
    printf '      %s✘ %s%s\n' "$_VERMELHO" "$1" "$_RESET" >&2
    shift
    for linha in "$@"; do
        printf '        %s%s%s\n' "$_APAGADO" "$linha" "$_RESET" >&2
    done
    exit 1   # estamos dentro do subshell do teste: só ele termina
}

# rodar_testes ARQUIVO_DE_TESTE ALVO
#   Carrega o arquivo de teste, descobre funções teste_* e executa cada uma.
#   Retorna 0 se todas passarem.
rodar_testes() {
    local arquivo_teste="$1" nome total=0 ok=0 dir_tmp
    ALVO="$(realpath -- "$2")"
    export ALVO

    # shellcheck source=/dev/null
    source "$arquivo_teste"

    # `declare -F` lista funções definidas; filtramos as que começam com teste_
    while read -r _ _ nome; do
        [[ "$nome" == teste_* ]] || continue
        (( total++ ))
        dir_tmp="$(mktemp -d)"
        # ( ... ) = subshell: cd, variáveis e `exit` não vazam para o runner
        if ( cd "$dir_tmp" && glab_simulado_reiniciar && "$nome" ); then
            (( ok++ ))
            printf '    %s✔%s %s\n' "$_VERDE" "$_RESET" "${nome#teste_}"
        else
            printf '    %s✘ %s%s\n' "$_VERMELHO" "${nome#teste_}" "$_RESET"
        fi
        rm -rf -- "$dir_tmp"
    done < <(declare -F)

    if (( total == 0 )); then
        printf '    %sNenhum teste encontrado em %s%s\n' "$_AMARELO" "$arquivo_teste" "$_RESET"
        return 1
    fi

    if (( ok == total )); then
        printf '  %s%s%d/%d testes passaram — mandou bem!%s\n' "$_NEGRITO" "$_VERDE" "$ok" "$total" "$_RESET"
        return 0
    fi
    printf '  %s%s%d/%d testes passaram — leia as dicas acima e tente de novo.%s\n' \
        "$_NEGRITO" "$_AMARELO" "$ok" "$total" "$_RESET"
    return 1
}
