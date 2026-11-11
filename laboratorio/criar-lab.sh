#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · laboratorio/criar-lab.sh
#  Cria o SEU projeto de laboratório no GitLab (GitLab.com ou o local), já
#  povoado com pipeline, CODEOWNERS, labels e issues — o cenário dos exemplos
#  GLAB_REAL=1.
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ============================================================================
#
#  USO
#    ./laboratorio/criar-lab.sh                 # cria seu-usuario/lab-gitlab (privado)
#    ./laboratorio/criar-lab.sh --nome meu-lab  # outro nome
#    ./laboratorio/criar-lab.sh --publico       # público
#    ./laboratorio/criar-lab.sh --simular       # mostra o que faria, sem internet
#    GITLAB_HOST=http://localhost:8080 ./laboratorio/criar-lab.sh   # no GitLab local
#
#  POR QUE PRIVADO POR PADRÃO?
#    No GitLab, privado e público têm os mesmos recursos do plano Free
#    (branches protegidas, CI, registry, Pages). Privado é o padrão seguro;
#    deixe público só se quiser mostrar o laboratório para alguém.
# ============================================================================
set -euo pipefail

AQUI="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
nome='lab-gitlab' visibilidade=private simular=0
while (( $# )); do
    case "$1" in
        --nome)    nome="${2:?--nome precisa de um valor}"; shift ;;
        --publico) visibilidade=public ;;
        --simular) simular=1 ;;
        -h|--help) sed -n '/^#  USO/,/^#  POR QUE/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        *) echo "opção desconhecida: $1 (use --help)" >&2; exit 2 ;;
    esac
    shift
done
[[ "$nome" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || { echo "nome inválido: $nome" >&2; exit 2; }

if (( simular )); then
    # shellcheck source=../ferramentas/lib/glab-simulado.sh
    source "$AQUI/../ferramentas/lib/glab-simulado.sh"
fi
command -v glab >/dev/null || { echo "instale o GitLab CLI: https://gitlab.com/gitlab-org/cli#installation" >&2; exit 1; }
glab auth status >/dev/null 2>&1 || { echo "faça login antes: glab auth login" >&2; exit 1; }

eu="$(glab api user)"
usuario="$(jq -r .username <<<"$eu")"
projeto="$usuario/$nome"
echo "➤ Criando o laboratório $projeto ($visibilidade)"

# 1. Projeto vazio pela API (sem README automático: o conteúdo vem do passo 2)
criado="$(glab api -X POST projects -f name="$nome" -f path="$nome" -f visibility="$visibilidade" \
    -f default_branch=main -F initialize_with_readme=false \
    -f description="Laboratório do Curso de GitLab (Prof. Daniel Santos)")"
url_git="$(jq -r .http_url_to_repo <<<"$criado")"

# 2. Conteúdo inicial, com o e-mail PRIVADO do GitLab como autor (Módulo 01)
tmp="$(mktemp -d)"; trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/.gitlab/issue_templates"
cat > "$tmp/README.md" <<MD
# 🧪 Laboratório do Curso de GitLab

Projeto de prática de **@$usuario** para o [Curso de GitLab](https://github.com/dsantos-docencia/gitlab)
do Prof. Daniel Santos. Conteúdo fictício — pode quebrar à vontade.
MD
printf '[Geral]\n* @%s\n' "$usuario" > "$tmp/.gitlab/CODEOWNERS"
printf '## O que aconteceu\n\n## Como reproduzir\n\n/label ~bug\n' > "$tmp/.gitlab/issue_templates/Bug.md"
cat > "$tmp/testes.sh" <<'SH'
#!/usr/bin/env bash
# Teste de mentira para o CI ter o que rodar.
set -euo pipefail
echo "✔ todos os testes passaram"
SH
chmod +x "$tmp/testes.sh"
cat > "$tmp/.gitlab-ci.yml" <<'YML'
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never
    - if: $CI_COMMIT_BRANCH
    - if: $CI_COMMIT_TAG

testes:
  image: alpine:3.22
  script:
    - apk add --no-cache bash
    - ./testes.sh
YML
email="$(jq -r '"\(.id)-\(.username)@users.noreply.\(env.GITLAB_HOST // "gitlab.com" | sub("^https?://"; "") | sub(":.*"; ""))"' <<<"$eu")"
git -C "$tmp" init -q -b main
git -C "$tmp" add .
git -C "$tmp" -c user.name="$usuario" -c user.email="$email" commit -q -m "chore: laboratório do Curso de GitLab"
if (( simular )); then
    echo "  (simulado) git push $url_git main"
else
    git -C "$tmp" push -q "$url_git" main
fi

# 3. Labels e issues de exemplo (os mesmos dados do simulador)
while IFS='|' read -r label cor descricao; do
    glab label create -R "$projeto" --name "$label" --color "$cor" --description "$descricao" >/dev/null
done <<'TSV'
bug|#d73a4a|Algo não funciona
melhoria|#a2eeef|Nova funcionalidade
documentação|#0075ca|Documentação
primeira contribuição|#7057ff|Bom para quem está começando
prioridade::alta|#b60205|Resolver primeiro
TSV
while IFS='|' read -r titulo labels; do
    glab issue create -R "$projeto" --title "$titulo" --description "Issue de exemplo do laboratório." \
        --label "$labels" --yes >/dev/null
done <<'TSV'
Erro 500 ao salvar o perfil|bug,prioridade::alta
Adicionar modo escuro|melhoria
Botão de login desalinhado no celular|bug
Documentar a API de pedidos|documentação,primeira contribuição
TSV

cat <<FIM

✅ Laboratório pronto: $(jq -r .web_url <<<"$criado")

Para rodar os exemplos no GitLab de verdade:
    export GLAB_REAL=1 LAB_PROJETO=$projeto
    bash modulos/03-issues-labels-e-boards/exemplos/01-ciclo-de-um-issue.sh

Para apagar quando terminar o curso:  ./laboratorio/destruir-lab.sh --nome $nome
FIM
if (( simular )); then
    echo; echo "── modo --simular: nada foi criado. Chamadas que seriam feitas:"
    chamadas_glab
fi
