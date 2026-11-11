#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 08 · Quantos jobs essa matriz gera?
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  calcular a expansão do parallel:matrix (soma dos produtos) e ver os nomes dos jobs
#  EXECUTE   bash modulos/08-gitlab-ci-avancado/exemplos/01-expandindo-a-matriz.sh
# ============================================================================
set -euo pipefail
CURSO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

# --- Laboratório descartável --------------------------------------------------
# Pasta temporária apagada ao final; Git isolado (não lê nem altera o seu
# ~/.gitconfig); identidade fixa para os commits de demonstração.
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT; cd "$LAB"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$LAB/.gitconfig-lab" GIT_PAGER=cat
export GIT_AUTHOR_NAME='Ana Dev' GIT_AUTHOR_EMAIL='ana@exemplo.dev'
export GIT_COMMITTER_NAME='Ana Dev' GIT_COMMITTER_EMAIL='ana@exemplo.dev'
git config --global init.defaultBranch main
git config --global advice.detachedHead false

# --- glab simulado (offline): cada chamada é registrada, nada vai à internet -
# shellcheck source=/dev/null
source "$CURSO/ferramentas/lib/glab-simulado.sh"
export LAB_PROJETO='aluno/laboratorio'
passo()  { printf '\n== %s ==\n' "$*"; }
enc()    { jq -rn --arg v "$1" '$v | @uri'; }   # dono/projeto → dono%2Fprojeto (a API do GitLab exige)
# mostra: exibe o comando (com aspas só onde precisa) e depois o executa
mostra() {
    local a linha='$'
    for a in "$@"; do
        if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
            if [[ "$a" == *$'\n'* ]]; then a="'${a%%$'\n'*} …'"        # texto longo: só a 1ª linha
            elif [[ "$a" == *"'"* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
        fi
        linha+=" $a"
    done
    printf '%s\n' "$linha" >&2; "$@"   # o comando vai p/ stderr: dá para usar mostra … | jq
}

cat > .gitlab-ci.yml <<'YAML'
testes:
  image: node:$VERSAO_NODE-alpine
  parallel:
    matrix:
      - VERSAO_NODE: ["20", "22", "24"]
        BANCO: [postgres, mysql]
      - VERSAO_NODE: "24"
        BANCO: sqlite
  script: npm test
YAML
passo "A matriz"; cat .gitlab-ci.yml
passo "Expansão: cada item é uma sub-matriz (produto); o total é a soma"
python3 "$CURSO/ferramentas/lib/yaml2json.py" .gitlab-ci.yml | python3 -c '
import itertools, json, sys
for i, sub in enumerate(json.load(sys.stdin)["testes"]["parallel"]["matrix"], 1):
    eixos = {k: (v if isinstance(v, list) else [v]) for k, v in sub.items()}
    combos = list(itertools.product(*eixos.values()))
    print(f"sub-matriz {i}: " + " × ".join(f"{k}({len(v)})" for k, v in eixos.items()) + f" = {len(combos)}")
    for c in combos: print("   testes: [" + ", ".join(c) + "]")
'
