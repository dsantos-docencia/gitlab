#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 04 · MR criado pelo próprio git push
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver as push options chegando ao servidor — com um repositório bare que registra o que recebeu
#  EXECUTE   bash modulos/04-merge-requests-e-code-review/exemplos/01-mr-por-push-options.sh
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

passo "Um 'GitLab' local: bare que anuncia suporte a push options e registra o que recebe"
git init -q --bare servidor.git
git -C servidor.git config receive.advertisePushOptions true
cat > servidor.git/hooks/pre-receive <<'HOOK'
#!/usr/bin/env bash
# O Git entrega as push options ao servidor em GIT_PUSH_OPTION_0, _1, ...
for ((i = 0; i < ${GIT_PUSH_OPTION_COUNT:-0}; i++)); do
    var="GIT_PUSH_OPTION_$i"; echo "servidor recebeu: ${!var}"
done
HOOK
chmod +x servidor.git/hooks/pre-receive

git clone -q servidor.git loja 2>/dev/null && cd loja
printf 'loja\n' > app.txt && git add . && git commit -q -m "feat: base" && git push -q origin main
git switch -q -c feature/login
printf 'login\n' > login.txt && git add . && git commit -q -m "feat: login por e-mail"

passo "Push com as opções de MR"
mostra git push -u origin feature/login \
    -o merge_request.create -o merge_request.target=main \
    -o "merge_request.title=feat: login por e-mail" -o merge_request.draft \
    -o merge_request.remove_source_branch 2>&1 | sed 's/^remote: //'
echo
echo "No GitLab de verdade, a resposta traz: 'View merge request for feature/login: https://…/-/merge_requests/7'"
