# Laboratório do Curso de GitLab — ambiente isolado e reproduzível
# Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

# git, jq, python3-yaml — o mínimo para exemplos e corretor
# shellcheck, bats       — qualidade dos scripts
# openssh-client         — remotos por SSH (Módulo 01)
RUN apt-get update && apt-get install -y --no-install-recommends \
        git bash coreutils findutils grep sed gawk procps less nano \
        jq python3 python3-yaml python3-pip pipx \
        shellcheck bats openssh-client openssl curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# GitLab CLI (glab) em versão FIXA, do release oficial, com checksum conferido.
# Por padrão o .deb é conferido contra o checksums.txt do mesmo release; para
# a garantia total (a que o Módulo 10 recomenda), fixe o hash você mesmo:
#   docker build --build-arg GLAB_SHA256=<sha256 do .deb> -t curso-gitlab:lab laboratorio
ARG GLAB_VERSAO=1.130.0
ARG GLAB_SHA256=""
RUN set -eu; arq="glab_${GLAB_VERSAO}_linux_$(dpkg --print-architecture).deb"; \
    base="https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSAO}/downloads"; \
    curl -fsSLo "/tmp/$arq" "$base/$arq"; \
    if [ -n "$GLAB_SHA256" ]; then echo "$GLAB_SHA256  /tmp/$arq" | sha256sum -c -; \
    else curl -fsSLo /tmp/checksums.txt "$base/checksums.txt"; \
         (cd /tmp && grep " $arq\$" checksums.txt | sha256sum -c -); fi; \
    apt-get install -y "/tmp/$arq"; rm -f /tmp/*.deb /tmp/checksums.txt

# Validador do schema oficial do .gitlab-ci.yml (offline) e linters do
# próprio repositório do curso, em versões fixas.
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install check-jsonschema==0.39.0 \
 && PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install actionlint-py==1.7.12.25 \
 && PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install zizmor==1.32.0

RUN useradd -m -s /bin/bash aluno
USER aluno
RUN git config --global init.defaultBranch main \
 && git config --global user.name  "Aluno do Laboratório" \
 && git config --global user.email "aluno@laboratorio.local" \
 && git config --global core.editor nano \
 && git config --global safe.directory /curso
WORKDIR /curso
CMD ["bash"]
