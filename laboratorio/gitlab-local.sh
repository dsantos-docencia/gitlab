#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · laboratorio/gitlab-local.sh
#  Atalhos para o GitLab CE + Runner locais (gitlab-local/docker-compose.yml).
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ============================================================================
#  USO
#    gitlab-local.sh subir           sobe e espera ficar saudável (3–6 min na 1ª vez)
#    gitlab-local.sh senha           senha inicial do root (o arquivo some em 24 h!)
#    gitlab-local.sh runner glrt-…   registra o runner com o token da tela "New instance runner"
#    gitlab-local.sh backup          gitlab-backup create (+ lembrete do gitlab-secrets.json)
#    gitlab-local.sh status | logs | parar
#    gitlab-local.sh apagar          remove containers E volumes (pede confirmação)
# ============================================================================
set -euo pipefail

AQUI="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
compose() { docker compose -f "$AQUI/gitlab-local/docker-compose.yml" "$@"; }
command -v docker >/dev/null || { echo "precisa do Docker: https://docs.docker.com/get-docker/" >&2; exit 1; }

case "${1:-}" in
    subir)
        compose up -d
        echo "Aguardando o GitLab ficar saudável (a 1ª inicialização demora)…"
        for _ in $(seq 120); do
            if compose exec -T gitlab curl -fsS http://localhost/-/readiness >/dev/null 2>&1; then
                echo "✔ GitLab no ar: http://localhost:8080  (usuário root — senha: $0 senha)"; exit 0
            fi
            sleep 5
        done
        echo "ainda não respondeu; acompanhe com: $0 logs" >&2; exit 1 ;;
    senha)
        compose exec -T gitlab grep '^Password:' /etc/gitlab/initial_root_password \
            || echo "arquivo já removido (24 h). Redefina: docker compose … exec gitlab gitlab-rake 'gitlab:password:reset[root]'" ;;
    runner)
        token="${2:-}"
        [[ "$token" == glrt-* ]] || { echo "uso: $0 runner glrt-…  (Admin → CI/CD → Runners → New instance runner)" >&2; exit 2; }
        # --url e --clone-url pelo nome do serviço: os jobs rodam em containers
        # na mesma rede do Compose, onde "localhost:8080" não existe.
        compose exec -T runner gitlab-runner register --non-interactive \
            --url http://gitlab --clone-url http://gitlab --token "$token" \
            --executor docker --docker-image alpine:3.22 --docker-network-mode gitlab-lab_default
        echo "✔ runner registrado — confira em Admin → CI/CD → Runners" ;;
    backup)
        compose exec -T gitlab gitlab-backup create
        echo "⚠ O backup NÃO inclui /etc/gitlab/gitlab-secrets.json nem gitlab.rb — copie-os também:"
        echo "  docker compose -f $AQUI/gitlab-local/docker-compose.yml cp gitlab:/etc/gitlab/gitlab-secrets.json ." ;;
    status) compose ps; compose exec -T gitlab gitlab-ctl status || true ;;
    logs)   compose logs -f --tail 100 gitlab ;;
    parar)  compose stop ;;
    apagar)
        read -r -p "Isto apaga o GitLab local e TODOS os dados (volumes). Digite APAGAR: " r
        [[ "$r" == APAGAR ]] || { echo "nada foi apagado"; exit 1; }
        compose down -v ;;
    *) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; [[ -n "${1:-}" ]] && exit 2; exit 0 ;;
esac
