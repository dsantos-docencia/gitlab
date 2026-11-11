# 🧰 Scripts reais

Ferramentas prontas para o dia a dia com o GitLab — cada uma com **testes** (rodados contra o `glab` simulado pela etapa 6 de `./ferramentas/verificar-tudo.sh`) e comentários explicando as decisões. Tudo o que **apaga** algo **simula por padrão** e só age com `--aplicar`.

Requisitos: `glab` autenticado (`glab auth login`), `jq`, `git` e Bash 4+ (o `auditar-pipeline.sh` também usa `python3` com PyYAML). Todos aceitam `-h` para a ajuda e funcionam com GitLab.com ou self-managed (`glab auth login --hostname gitlab.suaempresa.com`).

## Dia a dia

| Script | O que faz | Exemplo |
|---|---|---|
| [`clonar-grupo.sh`](dia-a-dia/clonar-grupo.sh) | clona todos os projetos de um grupo **com subgrupos**, mantendo a hierarquia de pastas, ou atualiza os existentes (`pull --ff-only`) | `./clonar-grupo.sh escola-dev ~/codigo` |
| [`minha-fila.sh`](dia-a-dia/minha-fila.sh) | MRs que pedem a sua revisão, seus MRs abertos e issues atribuídos a você | `./minha-fila.sh -g escola-dev` |
| [`sincronizar-labels.sh`](dia-a-dia/sincronizar-labels.sh) | aplica um conjunto padrão de labels (inclusive com escopo `prioridade::alta`); lista ou remove as que sobram | `./sincronizar-labels.sh escola-dev/loja --remover-extras` |

## CI/CD

| Script | O que faz | Exemplo |
|---|---|---|
| [`disparar-e-acompanhar.sh`](ci/disparar-e-acompanhar.sh) | dispara um pipeline com variáveis (corpo JSON montado pelo `jq`) e acompanha até o fim, saindo com o resultado | `./disparar-e-acompanhar.sh escola-dev/loja --var AMBIENTE=homologacao` |
| [`limpar-pipelines.sh`](ci/limpar-pipelines.sh) | apaga pipelines antigos (com logs e artefatos) para liberar armazenamento; nunca os que estão rodando | `./limpar-pipelines.sh escola-dev/loja --dias 120 --manter-padrao --aplicar` |

## Auditoria

| Script | O que faz | Exemplo |
|---|---|---|
| [`auditar-pipeline.sh`](auditoria/auditar-pipeline.sh) | revisão estática do `.gitlab-ci.yml`: imagens sem versão, `include` sem `ref`, componente `@~latest`, segredo no YAML, `CI_DEBUG_TRACE`, deploy em produção sem regra | `./auditar-pipeline.sh .gitlab-ci.yml ci/*.yml` |
| [`revisar-acessos.sh`](auditoria/revisar-acessos.sh) | membros por papel (diretos + herdados), Maintainers demais, contas bloqueadas, acesso alto sem expiração | `./revisar-acessos.sh --grupo escola-dev --json` |

## Release e backup

| Script | O que faz | Exemplo |
|---|---|---|
| [`notas-da-versao.sh`](release/notas-da-versao.sh) | notas de versão por Conventional Commits entre duas tags, pela API de comparação | `./notas-da-versao.sh escola-dev/loja v1.1.0 v1.2.0 --saida NOTAS.md` |
| [`exportar-issues.sh`](backup/exportar-issues.sh) | exporta todos os issues para JSON + índice Markdown (issues **não** vêm no `git clone`!) | `./exportar-issues.sh escola-dev/loja` |

## Por que assim?

- **Caminho codificado** (`escola-dev%2Floja`) sempre via `jq @uri` — nada de `sed` que esquece o acento ou o espaço.
- **`--paginate`** em toda listagem: sem ele, só os 20 primeiros.
- **Simulação por padrão** no que é destrutivo, e o `--aplicar` fica explícito no histórico do terminal.
- **Códigos de saída com significado** (0 ok · 1 achado/falha · 2 uso incorreto · 3 limite de tempo) — os scripts encaixam em pipelines e cron.

## Da comunidade

Scripts enviados por alunos e alunas ficam em [`comunidade/`](comunidade/), com crédito. Quer contribuir? Abra um issue com o template **“📜 Enviar um script para a comunidade”**.

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · código PolyForm-NC</sub>
