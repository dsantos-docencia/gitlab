# shellcheck shell=bash
# ============================================================================
#  Curso de GitLab — DevOps de Ponta a Ponta
#  ferramentas/lib/glab-simulado.sh — liga o glab simulado e oferece asserções
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/gitlab
#  © 2026 Daniel Santos — Código sob PolyForm Noncommercial 1.0.0 (veja LICENSE)
# ============================================================================
#
#  Ao ser carregado (source), este arquivo:
#    • coloca ferramentas/simulador/ na FRENTE do PATH → "glab" passa a ser o
#      simulador (o glab real continua instalado, só fica escondido);
#    • aponta GLAB_CONFIG_DIR para uma pasta temporária → nada do seu login real
#      é lido nem alterado;
#    • zera GITLAB_TOKEN/GLAB_TOKEN → nenhum token real vaza para um exemplo.
#
#  Funções para testes e exemplos:
#    chamadas_glab                    mostra o registro de chamadas
#    afirmar_chamou_glab PADRÃO [msg] alguma chamada casa com o glob PADRÃO
#    afirmar_nao_chamou_glab PADRÃO   nenhuma chamada casa com PADRÃO
#    contar_chamadas_glab PADRÃO      quantas chamadas casam
#    valor_opcao_glab PADRÃO OPÇÃO    valor de OPÇÃO (--title, -f…) na última
#                                   chamada que casa com PADRÃO
#    entrada_glab PADRÃO              corpo enviado por stdin (--input -)
#    simular_glab PADRÃO CONTEÚDO [CÓDIGO]  injeta uma resposta (vale antes do mapa padrão)
#
#  Os padrões são globs comparados com a chamada em formato LEGÍVEL (o mesmo
#  que chamadas_glab mostra, sem o "glab " inicial), por exemplo:
#    'issue create*'   "label create --name 'good first issue' *"   'mr merge*--squash*'
# ============================================================================

GLAB_SIMULADOR_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../simulador" && pwd)"
case ":$PATH:" in *":$GLAB_SIMULADOR_DIR:"*) ;; *) PATH="$GLAB_SIMULADOR_DIR:$PATH" ;; esac
export PATH GLAB_SIMULADOR_DIR

# glab_simulado_reiniciar — registro, mapa e configuração novos (o corretor
# chama isto antes de CADA caso de teste, para um não enxergar o outro).
glab_simulado_reiniciar() {
    local aux
    aux="$(mktemp -d)"
    export GLAB_SIMULADO_LOG="$aux/chamadas.log" GLAB_SIMULADO_MAPA="$aux/mapa.tsv"
    export GLAB_CONFIG_DIR="$aux/config-glab"
    mkdir -p -- "$GLAB_CONFIG_DIR"; : > "$GLAB_SIMULADO_LOG"
}
# Se já existe um registro (ex.: o corretor chamou um script que também carrega
# esta lib), reaproveitamos — senão as chamadas iriam para um registro órfão.
[[ -n "${GLAB_SIMULADO_LOG:-}" && -f "${GLAB_SIMULADO_LOG}" ]] || glab_simulado_reiniciar
export NO_PROMPT=1 GLAB_CHECK_UPDATE=false GLAB_SEND_TELEMETRY=false NO_COLOR=1
unset GITLAB_TOKEN GLAB_TOKEN OAUTH_TOKEN CI_JOB_TOKEN

# Só as linhas de chamada (os blocos de stdin ficam entre marcadores).
_linhas_glab() {
    awk '/^--- entrada padrão ---$/{d=1;next} /^--- fim ---$/{d=0;next} !d && /^glab /{print substr($0,6)}' \
        "$GLAB_SIMULADO_LOG" 2>/dev/null
}

# _linhas_legiveis — cada chamada como você a digitaria: aspas simples só
# onde precisa ('good first issue'). É neste formato que os PADRÕES casam.
_linhas_legiveis() {
    local l a saida
    local -a args
    while IFS= read -r l; do
        eval "args=($l)"
        saida='glab'
        for a in "${args[@]}"; do
            if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
                if [[ "$a" == *"'"* || "$a" == *$'\n'* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
            fi
            saida+=" $a"
        done
        printf '%s\n' "${saida#glab }"
    done < <(_linhas_glab)
}

chamadas_glab() { _linhas_legiveis | sed 's/^/glab /'; }

contar_chamadas_glab() {
    local n=0 l
    while IFS= read -r l; do
        # shellcheck disable=SC2053
        [[ "$l" == $1 ]] && n=$((n + 1))
    done < <(_linhas_legiveis)
    printf '%s\n' "$n"
}

afirmar_chamou_glab() {
    (( $(contar_chamadas_glab "$1") > 0 )) && return 0
    _falhar "${2:-o script não chamou: glab $1}" "chamadas registradas:" "$(chamadas_glab | sed 's/^/  /')"
}

afirmar_nao_chamou_glab() {
    (( $(contar_chamadas_glab "$1") == 0 )) && return 0
    _falhar "${2:-o script NÃO deveria chamar: glab $1}" "$(chamadas_glab | sed 's/^/  /')"
}

# valor_opcao_glab PADRÃO OPÇÃO — aceita "--title X" e "--title=X".
valor_opcao_glab() {
    local l bruta ultima='' i
    # Lê as duas versões lado a lado: casa o padrão na legível, usa a bruta.
    while IFS= read -r l && IFS= read -r bruta <&3; do
        # shellcheck disable=SC2053
        [[ "$l" == $1 ]] && ultima="$bruta"
    done < <(_linhas_legiveis) 3< <(_linhas_glab)
    [[ -n "$ultima" ]] || return 1
    local -a a
    # A linha foi gravada com printf %q: eval a reconstrói com segurança.
    eval "a=($ultima)"
    for ((i = 0; i < ${#a[@]}; i++)); do
        if [[ "${a[i]}" == "$2" ]]; then printf '%s\n' "${a[i+1]:-}"; return 0; fi
        if [[ "${a[i]}" == "$2="* ]]; then printf '%s\n' "${a[i]#"$2="}"; return 0; fi
    done
    return 1
}

# entrada_glab PADRÃO — corpo de stdin da última chamada que casa com PADRÃO.
entrada_glab() {
    local l linha='' dentro=0 buf='' achou=''
    while IFS= read -r l; do
        if [[ "$l" == '--- entrada padrão ---' ]]; then dentro=1; buf=''; continue; fi
        if [[ "$l" == '--- fim ---' ]]; then
            dentro=0
            # shellcheck disable=SC2053
            [[ "$linha" == $1 ]] && achou="$buf"
            continue
        fi
        if (( dentro )); then buf+="$l"$'\n'; continue; fi
        if [[ "$l" == 'glab '* ]]; then
            local -a a2; eval "a2=(${l#glab })"
            linha=''; local x
            for x in "${a2[@]}"; do
                if [[ "$x" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
                    if [[ "$x" == *"'"* || "$x" == *$'\n'* ]]; then printf -v x '%q' "$x"; else x="'$x'"; fi
                fi
                linha+="${linha:+ }$x"
            done
        fi
    done < "$GLAB_SIMULADO_LOG"
    printf '%s' "$achou"
}

simular_glab() {   # simular_glab PADRÃO CONTEÚDO [CÓDIGO]
    local arq
    arq="$(mktemp "$(dirname -- "$GLAB_SIMULADO_MAPA")/resposta.XXXXXX")"
    printf '%s\n' "$2" > "$arq"
    # O mapa do teste é consultado antes do padrão; prepend = o mais novo vence.
    { printf '%s\t%s\t%s\n' "$1" "$arq" "${3:-0}"; cat -- "$GLAB_SIMULADO_MAPA" 2>/dev/null || true; } > "$arq.mapa"
    mv -- "$arq.mapa" "$GLAB_SIMULADO_MAPA"
}


# Fallback de _falhar para quando a lib é usada fora do framework de testes.
declare -F _falhar >/dev/null || _falhar() { printf '✘ %s\n' "$@" >&2; return 1; }
