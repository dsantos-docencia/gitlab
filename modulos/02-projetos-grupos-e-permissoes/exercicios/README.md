# 🏋️ Exercícios — Módulo 02

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 02        # todos do módulo
./ferramentas/corrigir.sh 02 01     # só o exercício 01
```

Os exercícios treinam a criação via API, a configuração do projeto com caminho codificado e um relatório de membros.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Criar grupo e projeto · `01-grupo-e-projeto.sh`
O script recebe `NOME-DO-GRUPO CAMINHO-DO-GRUPO NOME-DO-PROJETO` e faz **duas** chamadas:
1. `glab api -X POST groups` com `-f name=NOME-DO-GRUPO`, `-f path=CAMINHO-DO-GRUPO` e `-f visibility=private`;
2. `glab repo create NOME-DO-PROJETO --group CAMINHO-DO-GRUPO --private --defaultBranch main`.

Valide o caminho do grupo: só letras minúsculas, números, `-`, `_` e `.`, começando por letra ou número (senão: stderr e saída **2**, sem chamar o `glab`). O nome pode ter espaços e acentos.

### 02 — Regras de merge pela API · `02-configurar-projeto.sh`
O script recebe `grupo/projeto` (pode ter subgrupos: `escola-dev/backend/api`) e faz **uma** chamada:
```bash
glab api -X PUT "projects/CAMINHO-CODIFICADO"   -f merge_method=ff -f squash_option=default_on   -F only_allow_merge_if_pipeline_succeeds=true   -F only_allow_merge_if_all_discussions_are_resolved=true   -F remove_source_branch_after_merge=true
```
O caminho precisa ir **codificado**: cada `/` vira `%2F` (use `jq -rn --arg v "$1" '$v|@uri'`). Sem argumento ou sem `/` → saída **2**.

### 03 — Membros por papel · `03-membros-por-papel.sh`
O script recebe `grupo/projeto` e, com `glab api --paginate "projects/CODIFICADO/members/all?per_page=100"`, imprime uma linha por papel **presente**, do maior para o menor, com os usuários em ordem alfabética:
```
Owner: aluno
Maintainer: ex-estagiario
Developer: bia-dev
Reporter: caio-qa
Planner: planejadora
```
Níveis: 10 Guest · 15 Planner · 20 Reporter · 30 Developer · 40 Maintainer · 50 Owner. Por último, se houver **mais de um** membro com nível ≥ 40, imprima `⚠ N pessoas podem alterar branches protegidas`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
