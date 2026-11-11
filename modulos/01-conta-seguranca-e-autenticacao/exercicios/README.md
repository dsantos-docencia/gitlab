# 🏋️ Exercícios — Módulo 01

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 01        # todos do módulo
./ferramentas/corrigir.sh 01 01     # só o exercício 01
```

Os exercícios treinam a identidade dos commits, a configuração SSH e a higiene com tokens.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — E-mail privado nos commits · `01-email-privado.sh`
O script recebe `ID` (numérico) e `USUARIO` e configura, **no nível local** do repositório `projeto` (crie-o com branch `main`):
- `user.name` = `USUARIO`
- `user.email` = `ID-USUARIO@users.noreply.gitlab.com` (com **hífen**)

Faltando argumento → uso em stderr e saída **2**. `ID` não numérico → stderr e saída **1**, sem criar nada.

### 02 — Config SSH com a porta 443 · `02-config-ssh.sh`
Crie `ssh/config` (na pasta atual) com dois blocos, opções indentadas com 4 espaços:

**`Host gitlab.com`** — `HostName gitlab.com`, `User git`, `IdentityFile ~/.ssh/id_ed25519_gitlab`, `IdentitiesOnly yes`.

**`Host gitlab-443`** — `HostName altssh.gitlab.com`, `Port 443`, `User git`, `IdentityFile ~/.ssh/id_ed25519_gitlab`.

Permissão `600`.

### 03 — Classificador de tokens do GitLab · `03-classificar-token.sh`
O script recebe um token em `$1` e imprime `TIPO · INÍCIO…` (INÍCIO = **9 primeiros caracteres**), sem jamais exibir o token inteiro:

| Prefixo | TIPO |
|---|---|
| `glpat-` | `acesso pessoal/projeto/grupo` |
| `gldt-` | `deploy token` |
| `glrt-` | `runner` |
| `glcbt-` | `ci job token` |
| `glptt-` | `gatilho de pipeline` |
| `glft-` | `feed` |

Ex.: `glpat-abcdefgh123` → `acesso pessoal/projeto/grupo · glpat-abc…`. Desconhecido → `desconhecido` em stderr e saída **1**; sem argumento → **2**.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
