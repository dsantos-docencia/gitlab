#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo 06 · Como o GitLab recusa um push
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  reproduzir offline as mensagens de branch protegida com um hook pre-receive
#  EXECUTE   bash modulos/06-branches-e-tags-protegidas/exemplos/03-push-recusado-localmente.sh
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

git init -q --bare servidor.git
cat > servidor.git/hooks/pre-receive <<'HOOK'
#!/usr/bin/env bash
zero=0000000000000000000000000000000000000000; erro=0
while read -r antigo novo ref; do
    [[ "$ref" == refs/heads/main ]] || continue
    if [[ "${DONO_DO_PUSH:-}" != gitlab-merge ]]; then
        echo "GitLab: You are not allowed to push code to protected branches on this project."; erro=1
    elif [[ "$antigo" != "$zero" ]] && ! git merge-base --is-ancestor "$antigo" "$novo"; then
        echo "GitLab: You are not allowed to force push code to a protected branch on this project."; erro=1
    fi
done
exit "$erro"
HOOK
chmod +x servidor.git/hooks/pre-receive

git clone -q servidor.git app 2>/dev/null && cd app
printf 'v1\n' > app.txt && git add . && git commit -q -m "feat: v1"
passo "O 'merge do GitLab' (o próprio servidor) pode atualizar a main"
DONO_DO_PUSH=gitlab-merge git push -q origin main && echo "✔ main criada pelo merge"
passo "Uma pessoa tenta push direto na main"
printf 'v2\n' > app.txt && git commit -qam "feat: v2"
git push origin main 2>&1 | sed 's/^/   /' || true
echo
echo "A saída correta é a do GitLab: branch → MR → merge pelo servidor."
