#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLabHub — Colaboração, Automação e Segurança
#  ferramentas/verificar-tudo.sh — Garantia de qualidade do repositório
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/gitlab
#  © 2026 Daniel Santos — Código sob PolyForm Noncommercial 1.0.0 (veja LICENSE)
# ============================================================================
#
#  Este script é a promessa do repositório: TODO exemplo aqui funciona.
#  Ele roda localmente e também no GitHub Actions a cada push/PR.
#
#  Etapas:
#    1. Sintaxe   — bash -n em todos os .sh (exceto scripts/comunidade/)
#    2. Lint      — shellcheck (se instalado)
#    2b. YAML     — todo .yml/.yaml é YAML válido
#    2c. Pipelines — schema oficial do .gitlab-ci.yml (check-jsonschema, se instalado)
#    2d. Workflows — actionlint e zizmor no CI deste repositório (se instalados)
#    3. Exemplos  — executa cada modulos/*/exemplos/*.sh e exige status 0
#    4. Soluções  — roda o corretor contra as soluções oficiais
#    5. Projetos  — roda os testes de cada projeto
#    6. Scripts   — roda os testes de scripts/testes/ contra scripts/*/
#    7. Laboratório — testes de laboratorio/testes/ (criar-lab.sh em modo --simular)
#
#  USO:  ./ferramentas/verificar-tudo.sh [--rapido]   (--rapido pula etapa 3)
# ============================================================================
set -uo pipefail

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$RAIZ" || exit 1

rapido=0
[[ "${1:-}" == "--rapido" ]] && rapido=1

if [[ -t 1 ]]; then V=$'\e[32m' R=$'\e[31m' A=$'\e[33m' N=$'\e[1m' Z=$'\e[0m'
else V='' R='' A='' N='' Z=''; fi

erros=0
titulo() { printf '\n%s== %s ==%s\n' "$N" "$1" "$Z"; }
ok()     { printf '  %s✔%s %s\n' "$V" "$Z" "$1"; }
falha()  { printf '  %s✘%s %s\n' "$R" "$Z" "$1"; (( erros++ )); }

# Lista de scripts, robusta a espaços no nome (-print0 + read -d '').
scripts=()
while IFS= read -r -d '' f; do
    scripts+=("$f")
done < <(find . -path ./scripts/comunidade -prune -o -path ./.git -prune -o -name '*.sh' -type f -print0 | sort -z)
scripts+=(./ferramentas/simulador/glab)   # o simulador não tem extensão .sh, mas é Bash

titulo "1. Sintaxe (bash -n) — ${#scripts[@]} arquivos"
n=0
for f in "${scripts[@]}"; do
    if bash -n "$f" 2>/dev/null; then (( n++ )); else falha "$f"; bash -n "$f"; fi
done
ok "$n arquivos com sintaxe válida"

titulo "2. ShellCheck"
if command -v shellcheck >/dev/null; then
    if shellcheck --severity=warning -x "${scripts[@]}"; then ok "nenhum aviso"; else falha "shellcheck encontrou problemas (acima)"; fi
else
    printf '  %s!%s shellcheck não instalado — etapa pulada (apt install shellcheck)\n' "$A" "$Z"
fi

titulo "2b. YAML válido"
n=0
while IFS= read -r -d '' y; do
    if python3 ferramentas/lib/yaml2json.py "$y" >/dev/null; then (( n++ )); else falha "$y"; fi
done < <(find . -path ./.git -prune -o \( -name '*.yml' -o -name '*.yaml' \) -type f -print0 | sort -z)
ok "$n arquivos YAML válidos"

titulo "2c. Schema oficial do GitLab CI (pipelines de exemplo, projetos e raiz)"
if command -v check-jsonschema >/dev/null; then
    # Componentes (pastas templates/) têm um documento "spec" antes do corpo e
    # não são um .gitlab-ci.yml completo — ficam de fora desta checagem.
    mapfile -d '' pls < <( { find modulos -path '*/pipelines/*' -name '*.yml' -not -path '*/templates/*' -type f -print0
                             find projetos -name '*.gitlab-ci.yml' -type f -print0
                             [[ -f .gitlab-ci.yml ]] && printf '%s\0' .gitlab-ci.yml; } 2>/dev/null | sort -z)
    if (( ${#pls[@]} )) && check-jsonschema --builtin-schema vendor.gitlab-ci "${pls[@]}"; then ok "${#pls[@]} pipelines válidos"
    elif (( ${#pls[@]} )); then falha "pipelines fora do schema (acima)"; fi
else
    printf '  %s!%s check-jsonschema não instalado — etapa pulada (pip install check-jsonschema)\n' "$A" "$Z"
fi

titulo "2d. Workflows deste repositório (actionlint + zizmor)"
if command -v actionlint >/dev/null; then
    actionlint -no-color .github/workflows/*.yml && ok "actionlint sem problemas" || falha "actionlint (acima)"
fi
if command -v zizmor >/dev/null; then
    zizmor --quiet --no-progress --offline .github/workflows && ok "zizmor sem achados" || falha "zizmor (acima)"
fi

if (( ! rapido )); then
    titulo "3. Execução dos exemplos"
    # Só os exemplos NUMERADOS (NN-...) são demos auto-executáveis que devem
    # sair com 0. Exemplos "ferramenta" (ex.: calculadora.sh) são exercitados
    # pelos seus testes Bats na etapa 3b, não rodados soltos aqui.
    for f in modulos/*/exemplos/[0-9]*.sh; do
        [[ -e "$f" ]] || continue
        tmp="$(mktemp -d)"
        # Cada exemplo roda num diretório vazio, sem teclado (stdin=/dev/null)
        # e com tempo limitado. Um exemplo didático não pode travar nem falhar.
        if saida="$(cd "$tmp" && timeout 60 bash "$RAIZ/$f" </dev/null 2>&1)"; then
            ok "$f"
        else
            falha "$f"; printf '%s\n' "$saida" | tail -n 15 | sed 's/^/      /'
        fi
        rm -rf -- "$tmp"
    done

    titulo "3b. Testes Bats (se instalado)"
    if command -v bats >/dev/null; then
        mapfile -t bats_files < <(find modulos -name '*.bats' | sort)
        if (( ${#bats_files[@]} )) && bats "${bats_files[@]}" >/tmp/bats.log 2>&1; then
            ok "$(grep -cE '^ok ' /tmp/bats.log) testes Bats passaram"
        elif (( ${#bats_files[@]} )); then
            falha "testes Bats falharam"; tail -n 20 /tmp/bats.log | sed 's/^/      /'
        else
            printf '  %s!%s nenhum arquivo .bats encontrado\n' "$A" "$Z"
        fi
    else
        printf '  %s!%s bats não instalado — etapa pulada (apt install bats)\n' "$A" "$Z"
    fi
fi

titulo "4. Soluções oficiais contra os testes"
if ./ferramentas/corrigir.sh --todos --solucao >/tmp/corrigir.log 2>&1; then
    ok "todas as soluções passam ($(grep -c '✔' /tmp/corrigir.log) casos de teste)"
else
    falha "alguma solução falhou"; grep -E '✘|▶' /tmp/corrigir.log | sed 's/^/    /'
fi

titulo "5. Testes dos projetos"
for t in projetos/*/testes/*.teste.sh; do
    [[ -e "$t" ]] || continue
    alvo="$(dirname -- "$(dirname -- "$t")")/$(basename -- "$t" .teste.sh).sh"
    # shellcheck source=lib/teste.sh
    if ( source ferramentas/lib/teste.sh; rodar_testes "$t" "$alvo" ) >/tmp/proj.log 2>&1; then
        ok "$t"
    else
        falha "$t"; sed 's/^/      /' /tmp/proj.log
    fi
done

titulo "6. Testes dos scripts reais (scripts/)"
declare -A alvo_de=()
while IFS= read -r -d '' s; do alvo_de["$(basename -- "$s" .sh)"]="$s"; done \
    < <(find scripts -path scripts/comunidade -prune -o -path scripts/testes -prune -o -name '*.sh' -type f -print0)
for t in scripts/testes/*.teste.sh; do
    [[ -e "$t" ]] || continue
    nome="$(basename -- "$t" .teste.sh)"
    alvo="${alvo_de[$nome]:-}"
    if [[ -z "$alvo" ]]; then falha "$t (script $nome.sh não encontrado)"; continue; fi
    # shellcheck source=lib/teste.sh
    if ( source ferramentas/lib/teste.sh; rodar_testes "$t" "$alvo" ) >/tmp/scr.log 2>&1; then
        ok "$alvo"
    else
        falha "$alvo"; sed 's/^/      /' /tmp/scr.log
    fi
done

titulo "7. Testes do laboratório"
for t in laboratorio/testes/*.teste.sh; do
    [[ -e "$t" ]] || continue
    alvo="laboratorio/$(basename -- "$t" .teste.sh).sh"
    # shellcheck source=lib/teste.sh
    if ( source ferramentas/lib/teste.sh; rodar_testes "$t" "$alvo" ) >/tmp/lab.log 2>&1; then
        ok "$alvo"
    else
        falha "$alvo"; sed 's/^/      /' /tmp/lab.log
    fi
done

echo
if (( erros == 0 )); then printf '%s%sRepositório íntegro.%s\n' "$N" "$V" "$Z"
else printf '%s%s%d problema(s) encontrado(s).%s\n' "$N" "$R" "$erros" "$Z"; fi
exit $(( erros > 0 ))
