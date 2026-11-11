# 🏋️ Exercícios — Módulo 00

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 00        # todos do módulo
./ferramentas/corrigir.sh 00 01     # só o exercício 01
```

Os exercícios treinam o Markdown do GitLab, a linguagem de referências e a configuração do `glab`.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — README com recursos do GitLab · `01-readme-glfm.sh`
Crie, na pasta atual, um `README.md` que use:
1. o sumário automático `[[_TOC_]]` numa linha sozinha;
2. um título de nível 1;
3. um **alerta** `> [!note]` (minúsculo, como na documentação do GitLab) seguido de uma linha `> ...`;
4. lista de tarefas com um item feito (`- [x]`), um pendente (`- [ ]`) e um **não aplicável** (`- [~]`, exclusivo do GitLab);
5. um bloco ` ```mermaid ` fechado corretamente.

### 02 — Gerador de referências do GitLab · `02-referencias.sh`
O script recebe `TIPO VALOR` e imprime a referência do GitLab correspondente:

| TIPO | VALOR | Saída |
|---|---|---|
| `issue` | `12` | `#12` |
| `mr` | `7` | `!7` |
| `epico` | `3` | `&3` |
| `snippet` | `5` | `$5` |
| `label` | `bug` | `~bug` |
| `label` | `precisa de revisão` | `~"precisa de revisão"` (tem espaço → aspas) |
| `milestone` | `v1.1` | `%v1.1` |
| `milestone` | `Sprint 4` | `%"Sprint 4"` |

Para `issue`, `mr`, `epico` e `snippet`, o valor precisa ser um número (senão: stderr e saída **1**). Tipo desconhecido ou faltando argumento → uso em stderr e saída **2**.

### 03 — Deixando o glab do seu jeito · `03-configurar-glab.sh`
Faça o script configurar o `glab` com estas chamadas (o corretor confere o registro do `glab` simulado):
1. `git_protocol` = `ssh`, **global** (`--global`);
2. `editor` = `code --wait`, global;
3. um alias `minhas` para `issue list --assignee=@me`;
4. um alias `revisar` para `mr list --reviewer=@me`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
