# 🏋️ Exercícios — Módulo 03

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 03        # todos do módulo
./ferramentas/corrigir.sh 03 01     # só o exercício 01
```

Os exercícios treinam templates com quick actions, labels em lote e triagem com `--output json` + `jq`.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Templates de issue com quick actions · `01-templates-de-issue.sh`
Crie em `.gitlab/issue_templates/`:

**`Bug.md`** com as seções (nível 2) `## Passos para reproduzir`, `## Comportamento esperado` e `## Comportamento atual`, nesta ordem, e terminando com a quick action `/label ~bug` numa linha sozinha.

**`Seguranca.md`** com uma seção `## O que você encontrou` e as quick actions `/label ~"segurança"` e `/confidential` (cada uma numa linha).

**`Default.md`** com qualquer conteúdo que inclua `/label ~"status::triagem"` — ele é aplicado a todo issue novo.

### 02 — Labels em lote (com a cor certa) · `02-labels-em-lote.sh`
O script recebe um TSV (`$1`: `nome<TAB>cor<TAB>descrição`) e um projeto (`$2`). Ignore linhas vazias e comentários (`#` no início). Para cada label, chame:
```bash
glab label create --name "NOME" --color "#COR" --description "DESCRIÇÃO" -R "PROJETO"
```
A cor no arquivo pode vir **com ou sem** `#` — a API do GitLab exige o `#`, então acrescente quando faltar (sem duplicar). No fim: `N labels criados`. Arquivo inexistente → saída **1**.

### 03 — A fila de triagem · `03-fila-de-triagem.sh`
O script recebe `grupo/projeto` e, com **uma** chamada `glab issue list -R PROJETO --output json --per-page 100`, imprime os issues **sem responsável**, em ordem crescente de número:
```
#9 Documentar a API de pedidos [documentação, primeira contribuição]
#10 Botão de login desalinhado no celular [bug]
#11 Adicionar modo escuro [melhoria]
```
(No GitLab, o número do issue no projeto é o campo `iid`; `id` é o identificador global.) Sem ninguém na fila: `fila vazia 🎉`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
