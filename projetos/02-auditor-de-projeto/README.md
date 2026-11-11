# Projeto 02 · Auditor de projeto

**Problema:** o grupo tem 40 projetos. Em quais a `main` aceita force push? Onde há senha em variável sem máscara? Qual webhook o GitLab desativou e ninguém percebeu? Quem ainda é Maintainer sem precisar?

**Solução:** [`auditor.sh`](auditor.sh) dá uma **nota de 0 a 10** a um projeto, consultando a API **só para leitura**, e sai com código ≠ 0 abaixo de um mínimo — dá para usar num pipeline agendado que audita o grupo inteiro toda semana.

```bash
./projetos/02-auditor-de-projeto/auditor.sh escola-dev/loja
./projetos/02-auditor-de-projeto/auditor.sh escola-dev/loja --minimo 9
./projetos/02-auditor-de-projeto/auditor.sh escola-dev/loja --json > auditoria-$(date +%F).json
```

```text
Auditoria de aluno/laboratorio
  ✔ descrição preenchida
  ✔ licença definida
  ✔ branch padrão protegida, sem force push
  ✔ tags v* protegidas
  ✔ merge só com pipeline verde
  ✘ merge só com discussões resolvidas
  ✘ no máximo 1 pessoa Maintainer ou acima (aluno, ex-estagiario)
  ✘ variáveis sensíveis mascaradas e protegidas (API_SENHA, AWS_SECRET_ACCESS_KEY)
  ✘ nenhum webhook desativado
  ✔ token do job restrito à allowlist
nota: 6/10
```

**Conceitos praticados:** API REST e codificação de caminhos (Módulo 11), branches e tags protegidas (Módulo 06), papéis (Módulo 02), variáveis, webhooks e token do job (Módulos 10 e 11), status HTTP como informação (`404` em `protected_branches/main` = não protegida).

**Decisões de projeto**
- **Só leitura** — o teste `so_leitura` garante que nenhum `-X POST/PUT/DELETE` acontece.
- Cada coleta falha “para o lado seguro”: sem permissão para ler variáveis, a lista vira `[]` — e o item é avaliado com o que se sabe. Num projeto real, rode com um token de **Maintainer** para ver tudo.
- Toda a avaliação está num único `jq` com `--argjson`: fácil de ler, de testar e de estender.

**Desafios para ir além**
1. Rode para **todos** os projetos de um grupo (`glab api --paginate "groups/…/projects?include_subgroups=true"`) e gere uma tabela Markdown ordenada pela nota.
2. Um pipeline agendado (Módulo 07) que roda o auditor no grupo e abre um **issue** com a tabela quando alguma nota cair.
3. Novos itens: “CODEOWNERS existe” (`repository/files/.gitlab%2FCODEOWNERS?ref=main`), “scanners de segurança no `.gitlab-ci.yml`”, “nenhum token de projeto vencendo em 30 dias”.

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · código PolyForm-NC, textos CC BY-NC-SA 4.0</sub>
