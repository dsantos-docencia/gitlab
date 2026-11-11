# 🏋️ Exercícios — Módulo 11

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 11        # todos do módulo
./ferramentas/corrigir.sh 11 01     # só o exercício 01
```

Os exercícios treinam um inventário com paginação, um receptor de webhook seguro e a criação idempotente de webhooks.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Inventário de projetos do grupo · `01-inventario-do-grupo.sh`
Escreva um script que recebe o caminho de um grupo (`escola-dev`) e gera um **CSV** na saída:

1. Sem argumento → **saída 2**.
2. Busque **todas as páginas** com `glab api --paginate "groups/<codificado>/projects?include_subgroups=true&per_page=100"`.
3. Ignore os projetos **arquivados** (filtre no `jq`).
4. Imprima o cabeçalho `caminho,visibilidade,ultima_atividade` e uma linha por projeto, em ordem alfabética de caminho; `ultima_atividade` só com a **data** (`2026-11-09`).

### 02 — Receptor de webhook seguro · `02-receptor-de-webhook.sh`
Escreva um script que processa **um** webhook: o JSON chega pela **entrada padrão**, o token recebido no cabeçalho `X-Gitlab-Token` chega como **1º argumento**, e o segredo esperado está na variável `WEBHOOK_SEGREDO`.

1. `WEBHOOK_SEGREDO` vazia ou sem argumento → **saída 2**.
2. Token diferente do segredo → `token inválido` no **stderr** e **saída 1** (sem processar nada).
3. Conforme `object_kind`, imprima:
   - `merge_request` com `object_attributes.action == "merge"` → `MR !<iid> mesclado em <target_branch> por <user.username>`
   - `push` → `push em <branch>: <total_commits_count> commit(s)` (branch sem o `refs/heads/`)
   - `pipeline` com `object_attributes.status == "failed"` → `ALERTA pipeline <id> falhou em <ref>`
   - qualquer outro caso → `ignorado: <object_kind>`

### 03 — Criar webhook sem duplicar · `03-criar-webhook.sh`
Escreva um script `<grupo/projeto> <url>` que cadastra um webhook de **MRs e pipelines** (sem push):

1. Faltou argumento, URL que **não** começa com `https://` ou `WEBHOOK_SEGREDO` vazia → **saída 2**.
2. Liste os webhooks (`glab api projects/<codificado>/hooks`). Se já houver um com a **mesma URL** → `já existe` e **saída 0**, sem criar.
3. Senão: `glab api -X POST projects/<codificado>/hooks -f url=<url> -f token="$WEBHOOK_SEGREDO" -F merge_requests_events=true -F pipeline_events=true -F push_events=false -F enable_ssl_verification=true`.
4. Depois, avise de webhooks existentes com `alert_status` igual a `disabled`: `ATENÇÃO webhook <id> desativado: <url>` (no stderr).

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
