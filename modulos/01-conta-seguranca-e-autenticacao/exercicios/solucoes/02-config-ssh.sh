#!/usr/bin/env bash
# Curso de GitLab · Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC · não comercial)
# Exercício 01.02 — Config SSH com a porta 443 · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p ssh
cat > ssh/config <<'CFG'
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
    IdentitiesOnly yes

Host gitlab-443
    HostName altssh.gitlab.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
CFG
chmod 600 ssh/config
