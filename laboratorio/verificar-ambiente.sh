#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · laboratorio/verificar-ambiente.sh
#  Confere se a sua máquina tem o necessário para o curso (e o que é opcional).
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ============================================================================
set -uo pipefail

faltam=0
item() {   # item OBRIGATÓRIO(1/0) COMANDO DESCRIÇÃO [comando de versão]
    local obrig="$1" cmd="$2" desc="$3" versao="${4:-}"
    if command -v "$cmd" >/dev/null 2>&1; then
        printf '  ✔ %-17s %s %s\n' "$cmd" "$desc" "${versao:+($(eval "$versao" 2>/dev/null | head -1))}"
    elif (( obrig )); then
        printf '  ✘ %-17s %s — OBRIGATÓRIO\n' "$cmd" "$desc"; faltam=$((faltam + 1))
    else
        printf '  · %-17s %s — opcional\n' "$cmd" "$desc"
    fi
}
echo "Obrigatórios (exemplos simulados e corretor):"
item 1 bash    "shell"                 'bash --version'
item 1 git     "Git"                   'git --version'
item 1 jq      "filtros JSON"          'jq --version'
item 1 python3 "conversor YAML→JSON"   'python3 --version'
if python3 -c 'import yaml' 2>/dev/null; then echo "  ✔ PyYAML            módulo yaml do Python"
else echo "  ✘ PyYAML            módulo yaml do Python — OBRIGATÓRIO (pip install pyyaml / apt install python3-yaml)"; faltam=$((faltam + 1)); fi
echo "Para o GitLab de verdade e ferramentas extras:"
item 0 glab              "GitLab CLI"                          'glab --version'
item 0 check-jsonschema  "schema oficial do .gitlab-ci.yml"    'check-jsonschema --version'
item 0 shellcheck        "lint de scripts"                     'shellcheck --version | sed -n 2p'
item 0 curl              "API e webhooks (Módulo 11)"          'curl --version'
item 0 docker            "GitLab local e container do curso"   'docker --version'
item 0 gitlab-ci-local   "rodar .gitlab-ci.yml localmente"     'gitlab-ci-local --version'
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "  ✔ docker compose    $(docker compose version --short 2>/dev/null)"
fi
if command -v glab >/dev/null 2>&1; then
    if glab auth status >/dev/null 2>&1; then echo "  ✔ glab logado como $(glab api user 2>/dev/null | jq -r .username)"
    else echo "  · glab instalado, mas sem login (glab auth login) — só necessário para GLAB_REAL=1"; fi
fi
echo
if (( faltam )); then echo "Faltam $faltam item(ns) obrigatório(s)."; exit 1; fi
echo "Tudo pronto para o curso. 🚀"
