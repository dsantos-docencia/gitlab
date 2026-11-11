# 🏋️ Exercícios — Módulo 04

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 04        # todos do módulo
./ferramentas/corrigir.sh 04 01     # só o exercício 01
```

Os exercícios treinam CODEOWNERS com seções, template de MR e um MR criado por push options.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — CODEOWNERS com seções · `01-codeowners-com-secoes.sh`
Crie `.gitlab/CODEOWNERS` com:
1. a regra geral `* @aluno` como **primeira** regra (antes de qualquer seção);
2. a seção `[Frontend]` com dono padrão `@bia-dev` na mesma linha, seguida das regras **sem dono** `*.js` e `*.css`;
3. a seção `[Documentação]` com a regra `/docs/ @escola-dev/docs`;
4. a seção **opcional** `^[Opcional]` com a regra `*.md @caio-qa`.

### 02 — Template de merge request · `02-template-de-mr.sh`
Crie `.gitlab/merge_request_templates/Default.md` (aplicado a todo MR novo) com:
- as seções `## O que muda`, `## Por quê` e `## Como testar`, nesta ordem;
- uma linha com `Closes #` (lembrete de ligar o issue);
- `## Checklist` com pelo menos 3 itens `- [ ]`;
- no final, as quick actions `/assign me` e `/label ~"status::revisão"`, cada uma numa linha.

### 03 — MR criado pelo git push · `03-mr-por-push.sh`
Os testes criam `app` (clone de um servidor bare que **registra as push options recebidas**) e deixam você numa branch de funcionalidade com commits. O script recebe o número de um issue (`$1`) e, dentro de `app`, faz **um único** `git push` que:
- publica a branch atual ligando o upstream (`-u`);
- envia as opções `merge_request.create`, `merge_request.target=main`, `merge_request.title=<assunto do último commit>`, `merge_request.description=Closes #<issue>` e `merge_request.remove_source_branch`.

Sem número válido → saída **2**, sem push.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
