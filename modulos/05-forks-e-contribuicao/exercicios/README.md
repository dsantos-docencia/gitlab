# 🏋️ Exercícios — Módulo 05

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 05        # todos do módulo
./ferramentas/corrigir.sh 05 01     # só o exercício 01
```

Os exercícios treinam a checagem dos arquivos de comunidade, a sincronização de forks e a licença via API.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Checklist do projeto pronto para contribuições · `01-saude-do-projeto.sh`
O script recebe uma pasta (`$1`, padrão `.`) e verifica 7 itens, imprimindo `✔ ITEM` ou `✘ ITEM` e no fim `nota: N/7` (saída **0** só com 7/7, senão **1**; pasta inexistente → **2**):

| Item | Aceita (na raiz ou em `docs/`) |
|---|---|
| `README` | `README.md` |
| `LICENSE` | `LICENSE` ou `LICENSE.md` |
| `CONTRIBUTING` | `CONTRIBUTING.md` |
| `CHANGELOG` | `CHANGELOG.md` |
| `SECURITY` | `SECURITY.md` |
| `ISSUE_TEMPLATES` | a pasta `.gitlab/issue_templates` com pelo menos um `.md` |
| `MR_TEMPLATES` | a pasta `.gitlab/merge_request_templates` com pelo menos um `.md` |

### 02 — Sincronizar o fork · `02-sincronizar-fork.sh`
Os testes criam `upstream.git`, `fork.git` e o clone `meu-fork` (origin = fork) e adicionam commits no original. O script recebe a URL do upstream e, em `meu-fork`:
1. adiciona o remoto `upstream` **se não existir** (idempotente);
2. faz fetch; 3. avança a `main` **só por fast-forward**; 4. envia ao `origin`;
5. imprime `fork sincronizado em <hash curto>`.

Se a `main` do fork divergiu, falhe sem enviar nada.

### 03 — Licença preenchida pela API · `03-licenca-via-api.sh`
O script recebe `CHAVE PROJETO NOME` (ex.: `mit "Loja do Bairro" "Ana Dev"`) e grava em `LICENSE` o campo `content` de:
```bash
glab api "templates/licenses/CHAVE?project=PROJETO-CODIFICADO&fullname=NOME-CODIFICADO"
```
Os parâmetros precisam ir **codificados** (espaço → `%20`, `&` → `%26`…) — use `jq -rn --arg v "…" '$v|@uri'`. Faltando argumento → **2**. Se a API falhar → saída **1** e **nenhum** `LICENSE` deixado para trás.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
