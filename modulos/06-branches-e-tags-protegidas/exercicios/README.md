# 🏋️ Exercícios — Módulo 06

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 06        # todos do módulo
./ferramentas/corrigir.sh 06 01     # só o exercício 01
```

Os exercícios aplicam proteção como código — de forma idempotente — e auditam uma branch.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Proteger a main (idempotente) · `01-proteger-branch.sh`
O script recebe `grupo/projeto` e protege a `main` com: push **ninguém** (`push_access_level=0`), merge **Developers+** (`merge_access_level=30`) e **sem** force push.

Como `POST` numa branch já protegida dá erro 409, o script deve:
1. consultar `glab api "projects/COD/protected_branches/main"`;
2. se existir (comando com sucesso) → `glab api -X DELETE "projects/COD/protected_branches/main"`;
3. `glab api -X POST "projects/COD/protected_branches" -f name=main -F push_access_level=0 -F merge_access_level=30 -F allow_force_push=false`;
4. imprimir `main protegida em grupo/projeto`.

`COD` = caminho codificado. Sem `/` no argumento → **2**.

### 02 — Proteger as tags de versão · `02-proteger-tags.sh`
O script recebe `grupo/projeto` e um padrão de tag (padrão: `v*`) e garante que só **Maintainers** (40) criam tags com esse padrão, de forma idempotente:
1. `glab api "projects/COD/protected_tags/TAG-COD"` — o **nome da tag também vai codificado** (`v*` → `v%2A`);
2. se existir → `glab api -X DELETE "projects/COD/protected_tags/TAG-COD"`;
3. `glab api -X POST "projects/COD/protected_tags" -f name=PADRÃO -F create_access_level=40`.

### 03 — Auditoria de uma branch protegida · `03-auditar-branch.sh`
O script recebe `grupo/projeto` e uma branch (padrão `main`), consulta `glab api "projects/COD/protected_branches/BRANCH"` e verifica, nesta ordem:
- `push direto bloqueado` — **todos** os `push_access_levels[].access_level` são `0`;
- `merge restrito` — o menor `merge_access_levels[].access_level` é **≥ 30**;
- `force push bloqueado` — `allow_force_push` é `false`.

Imprima `✔ item` / `✘ item`; saída **0** se tudo ok, **1** se algo falhou. Se a branch **não estiver protegida** (o `glab` falha), imprima `✘ branch não protegida` e saia com **1**. Com os dados de exemplo, o push está liberado para Maintainers.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
