# Módulo 11 · API, webhooks, espelhamento e administração

> **Você vai sair daqui sabendo:** automatizar o GitLab pela **API REST v4** (com paginação) e pela **GraphQL**, escolher o **token certo** para cada robô, receber **webhooks** com segurança, **espelhar** repositórios entre plataformas e cuidar de uma instância **self-managed**: backup, restauração e atualização pelo caminho obrigatório.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

A Escola Dev cresceu: 140 projetos em 12 subgrupos. A coordenação quer um inventário semanal, o chat da equipe precisa avisar quando um pipeline da `main` falha, o repositório principal tem que ter uma cópia em outro servidor, e a instância self-managed da escola está três versões atrás. Nada disso se faz clicando.

## 2. REST API v4

```bash
glab api user                                                    # GET é o padrão
glab api "projects/escola-dev%2Floja/issues?state=opened&labels=bug"
glab api -X POST "projects/escola-dev%2Floja/issues" -f title="Bug no checkout" -f labels=bug
glab api --paginate "groups/escola-dev/projects?include_subgroups=true&per_page=100"
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/777"
```

| Detalhe | Por quê |
|---|---|
| **Caminho codificado** (`escola-dev%2Floja`) ou **ID numérico** | a `/` do caminho seria lida como separador de URL |
| `-f` (texto) × `-F` (tipado: `true`, `30`, `@arquivo`) | `-F merge_access_level=30` envia número, não `"30"` |
| **Paginação**: `per_page` até 100; cabeçalhos `x-next-page`, `x-total` | sem `--paginate` você recebe só a 1ª página (20 itens) |
| **Keyset** (`pagination=keyset&order_by=id`) | listas enormes sem ficar lento |
| **Limites de taxa** (GitLab.com) | `429 Too Many Requests` → respeite `Retry-After` |

## 3. GraphQL

Um pedido, só os campos de que você precisa:

```bash
glab api graphql -f query='
  query($caminho: ID!) {
    project(fullPath: $caminho) {
      issues(state: opened) { count }
      mergeRequests(state: opened) { count }
    }
  }' -f caminho=escola-dev/loja
```

Explore o schema em **`/-/graphql-explorer`** da sua instância. Regra prática: REST para **ações**, GraphQL para **relatórios** que cruzam muitos objetos.

## 4. Qual token para qual robô?

| Token | Prefixo | Pertence a | Use para |
|---|---|---|---|
| Pessoal (PAT) | `glpat-` | você | scripts **seus**, na sua máquina |
| **De projeto** / **de grupo** | `glpat-` | um bot do projeto/grupo | integrações (o bot sai junto com o projeto, não com a pessoa) |
| **Service account** (Premium+) | `glpat-` | conta de serviço | automações que atravessam muitos grupos |
| Deploy token | `gldt-` | o projeto | só ler/escrever repositório e registry |
| Do job (`CI_JOB_TOKEN`) | `glcbt-` | o job em execução | chamar a API **de dentro** do pipeline |
| De gatilho | `glptt-` | o projeto | disparar pipelines de fora |

> 🔐 Sempre: **menor escopo** (`read_api` em vez de `api`), **data de validade** (máx. 365 dias por padrão) e **rotação** (`POST /personal_access_tokens/self/rotate`). No GitLab.com, tokens de projeto/grupo são Premium+; no self-managed, existem em todos os planos.

## 5. Webhooks

O GitLab faz um `POST` JSON para a sua URL a cada evento escolhido:

| Cabeçalho | Conteúdo |
|---|---|
| `X-Gitlab-Event` | `Push Hook`, `Merge Request Hook`, `Pipeline Hook`… |
| `X-Gitlab-Token` | o **segredo** que você definiu — confira **sempre** |
| `X-Gitlab-Event-UUID` / `Idempotency-Key` | identifica a entrega (deduplicar reenvios) |

```bash
glab api -X POST "projects/escola-dev%2Floja/hooks" \
  -f url=https://chat.exemplo.dev/gitlab -f token="$WEBHOOK_SEGREDO" \
  -F pipeline_events=true -F merge_requests_events=true -F push_events=false \
  -F enable_ssl_verification=true
```

- Responda **rápido** (2xx em poucos segundos) e processe depois, numa fila.
- Falhas seguidas **desativam** o webhook (primeiro temporariamente, depois de vez) — veja `alert_status`.
- **Webhooks de grupo** (Premium) valem para todos os projetos do grupo; **system hooks** (admin) valem para a instância.
- Compare o token em **tempo constante** (`hmac.compare_digest` no Python).

## 6. Espelhamento

| Tipo | Direção | Plano |
|---|---|---|
| **Push mirror** | GitLab → outro servidor (GitHub, Bitbucket, outro GitLab) | todos |
| **Pull mirror** | outro servidor → GitLab | Premium+ |

```bash
glab api -X POST "projects/escola-dev%2Floja/remote_mirrors" \
  -f url="https://usuario:${TOKEN_DESTINO}@gitlab.exemplo.dev/espelho/loja.git" \
  -F enabled=true -F only_protected_branches=true
```

Manual, em qualquer lugar: `git clone --mirror ORIGEM && git push --mirror DESTINO`. Para **migrar** de verdade (issues, MRs, wiki), use o **importador** (*New project → Import*) ou a **migração direta** entre instâncias GitLab.

## 7. Administração self-managed

```bash
# Backup (repositórios, banco, uploads, artefatos…)
sudo gitlab-backup create                         # Docker: docker exec -t gitlab gitlab-backup create
# NÃO estão no backup — guarde à parte, em outro lugar:
#   /etc/gitlab/gitlab-secrets.json   (sem ele, os dados criptografados ficam ilegíveis)
#   /etc/gitlab/gitlab.rb             (a configuração)

sudo gitlab-ctl status                            # serviços
sudo gitlab-rake gitlab:check SANITIZE=true       # diagnóstico completo
sudo gitlab-rake gitlab:env:info                  # versões
```

**Atualizar**: nunca pule as **paradas obrigatórias** (*required upgrade stops*): o banco precisa das migrações de cada uma. Use o **Upgrade Path tool** para montar a sequência, faça backup antes, e leia as *breaking changes* das versões maiores (o 20.0, por exemplo, remove os registration tokens de runner e a release-cli).

## 8. Armadilhas comuns

- **Script com o seu PAT em produção**: você sai da empresa, a integração para (ou pior, continua com o seu nome).
- **Webhook sem conferir `X-Gitlab-Token`**: qualquer um que descubra a URL dispara a sua automação.
- **Restaurar backup sem o `gitlab-secrets.json`**: tokens de runner, 2FA e variáveis de CI viram lixo.
- **Esquecer `--paginate`**: o relatório “funciona” — com só 20 projetos.

## 📚 Fontes oficiais

- REST API: <https://docs.gitlab.com/api/rest/>
- Paginação da API: <https://docs.gitlab.com/api/rest/#pagination>
- GraphQL: <https://docs.gitlab.com/api/graphql/>
- `glab api`: <https://gitlab.com/gitlab-org/cli/-/blob/main/docs/source/api/_index.md>
- Tokens (visão geral): <https://docs.gitlab.com/security/tokens/>
- Tokens de projeto: <https://docs.gitlab.com/user/project/settings/project_access_tokens/>
- Service accounts: <https://docs.gitlab.com/user/profile/service_accounts/>
- Webhooks: <https://docs.gitlab.com/user/project/integrations/webhooks/>
- Eventos de webhook: <https://docs.gitlab.com/user/project/integrations/webhook_events/>
- API de webhooks: <https://docs.gitlab.com/api/project_webhooks/>
- Espelhamento: <https://docs.gitlab.com/user/project/repository/mirror/>
- Backup e restauração: <https://docs.gitlab.com/administration/backup_restore/>
- Caminhos de atualização: <https://docs.gitlab.com/update/upgrade_paths/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
