#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab — laboratorio/entrar.sh
#  Abre um terminal dentro do container do curso, com o repositório montado.
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ============================================================================
set -euo pipefail

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGEM="curso-gitlab:lab"

if ! command -v docker >/dev/null; then
    cat >&2 <<'MSG'
Docker não encontrado. Instale a partir de https://docs.docker.com/get-docker/
Sem Docker, você usa o curso direto na sua máquina (Bash, Git, glab, jq e python3) — o container é só
uma conveniência para ter um ambiente idêntico e descartável.
MSG
    exit 1
fi

# Constrói a imagem na primeira vez (ou depois de: docker rmi curso-gitlab:lab).
if ! docker image inspect "$IMAGEM" >/dev/null 2>&1; then
    echo "Construindo a imagem do laboratório (só na primeira vez)…"
    docker build -t "$IMAGEM" "$RAIZ/laboratorio"
fi

echo "Entrando no laboratório. O repositório está em /curso. Digite 'exit' para sair."
# --rm: descartado ao sair · -v: o repositório do curso montado em /curso
# Para usar o GitLab de verdade dentro do container, repasse um token:
#   GITLAB_TOKEN=glpat-… ./laboratorio/entrar.sh        (o glab lê GITLAB_TOKEN)
# --network host: alcança o GitLab local (http://localhost:8080) do gitlab-local.sh
exec docker run --rm -it --network host -v "$RAIZ:/curso" \
    ${GITLAB_TOKEN:+-e GITLAB_TOKEN} ${GITLAB_HOST:+-e GITLAB_HOST} "$IMAGEM" bash
