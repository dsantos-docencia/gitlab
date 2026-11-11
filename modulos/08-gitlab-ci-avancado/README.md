# Módulo 08 · GitLab CI/CD: avançado

> **Você vai sair daqui sabendo:** multiplicar jobs com `parallel:matrix`, acelerar com `cache`, eliminar repetição com `extends`, `!reference`, `include` e — o recurso mais importante dos últimos anos — **componentes de CI/CD** com `spec:inputs` e o **CI/CD Catalog**; dividir pipelines em **pai e filho**; implantar com **ambientes**; trocar segredos de nuvem por **ID tokens (OIDC)**; e instalar o **seu próprio GitLab Runner**.

⏱ 5–6 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

Dez projetos da Escola Dev copiam o mesmo `.gitlab-ci.yml` de 200 linhas — e cada um já divergiu. O monorepo roda o pipeline inteiro mesmo quando só o frontend mudou. O deploy usa uma chave da nuvem guardada há dois anos. E os 400 minutos do mês acabaram no dia 12. Este módulo resolve cada um desses problemas.

## 2. Matriz

```yaml
testes:
  image: node:$VERSAO_NODE-alpine
  parallel:
    matrix:
      - VERSAO_NODE: ["20", "22", "24"]
        BANCO: [postgres, mysql]          # 3 × 2 = 6 jobs
      - VERSAO_NODE: "24"
        BANCO: sqlite                     # + 1 job = 7
  script: npm test
```

Cada item da lista é uma “sub-matriz”: o total é a **soma** dos produtos. Os jobs aparecem como `testes: [20, postgres]`. Use `needs: [{job: testes, parallel: {matrix: [...]}}]` para depender de uma combinação específica.

## 3. Cache × artefatos

| | `cache` | `artifacts` |
|---|---|---|
| Para quê | acelerar (dependências) | entregar (resultado de um job) |
| Garantido? | não — “se tiver, ótimo” | sim, para os jobs seguintes |
| Chave | `key:` fixa, por branch (`$CI_COMMIT_REF_SLUG`) ou por arquivos | — |

```yaml
cache:
  key:
    files: [package-lock.json]     # muda o lockfile → muda a chave → cache novo
  paths: [.npm/]
  policy: pull-push                # pull = só lê (jobs que não instalam nada)
```

## 4. Reaproveitando configuração

| Recurso | Escopo | Exemplo |
|---|---|---|
| **Âncoras YAML** (`&`, `*`, `<<:`) | o mesmo arquivo | `<<: *padrao` |
| **`extends`** | jobs “ocultos” (nome com `.`) | `extends: .node` (merge profundo) |
| **`!reference`** | pedaços de outro job | `script: [!reference [.setup, script], npm test]` |
| **`include: local`** | outro arquivo do projeto | `- local: ci/testes.yml` |
| **`include: project`** | arquivo de outro projeto, numa **versão fixa** | `- project: escola-dev/ci` · `ref: v1.4.0` · `file: node.yml` |
| **`include: template`** | templates oficiais | `- template: Jobs/SAST.gitlab-ci.yml` |
| **`include: component`** | **componente** do CI/CD Catalog | abaixo |

## 5. Componentes de CI/CD e o Catalog

Um **componente** é um bloco de pipeline reutilizável, **versionado** e com **entradas tipadas**. Fica num projeto próprio, em `templates/`:

```yaml
# templates/testes.yml  (projeto escola-dev/componentes)
spec:
  inputs:
    stage:
      default: test
    versao_node:
      type: string
      default: "22"
      description: Versão do Node
---
testes-node-$[[ inputs.versao_node ]]:
  stage: $[[ inputs.stage ]]
  image: node:$[[ inputs.versao_node ]]-alpine
  script: [npm ci, npm test]
```

```yaml
# .gitlab-ci.yml de quem usa
include:
  - component: $CI_SERVER_FQDN/escola-dev/componentes/testes@1.2.0
    inputs:
      versao_node: "24"
```

- `$[[ inputs.x ]]` é resolvido **ao montar o pipeline** (não é variável de ambiente).
- Versões: `@1.2.0` (fixa — recomendado), `@1.2` / `@1` (a última compatível), `@~latest` (a mais nova — evite em produção), ou um SHA.
- Publicar no **CI/CD Catalog**: marcar o projeto como *CI/CD Catalog project* e criar uma **release** com tag SemVer (Módulo 09).

## 6. Pipelines pai-filho e multi-projeto

```yaml
frontend:
  trigger:
    include: frontend/.gitlab-ci.yml     # pipeline FILHO, só quando o frontend muda
    strategy: depend                     # o pai espera e herda o status do filho
  rules:
    - changes: [frontend/**/*]

implantar-infra:
  trigger:
    project: escola-dev/infra            # pipeline de OUTRO projeto (multi-projeto)
    branch: main
```

## 7. Ambientes e implantação

```yaml
deploy-producao:
  stage: deploy
  script: ./deploy.sh
  environment:
    name: producao
    url: https://loja.exemplo.dev
  resource_group: producao               # um deploy por vez neste ambiente
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual                       # botão ▶ no pipeline
```

*Operate → Environments* mostra o que está implantado onde, com **rollback** em um clique. **Ambientes protegidos** (quem pode implantar, aprovações de deploy) são Premium.

## 8. ID tokens (OIDC): nuvem sem segredo guardado

```yaml
deploy:
  id_tokens:
    TOKEN_AWS:
      aud: https://gitlab.com            # o "público" que a nuvem espera
  script:
    - aws sts assume-role-with-web-identity --role-arn "$ROLE_ARN" --role-session-name ci --web-identity-token "$TOKEN_AWS"
```

O GitLab emite um JWT assinado dizendo “sou o job X do projeto Y, na ref Z”. A nuvem confia no GitLab e devolve credenciais **temporárias** — nada de chave fixa em variável.

## 9. O seu GitLab Runner

Runner próprio = minutos ilimitados, hardware que você escolher, acesso à rede interna.

```bash
# 1) No GitLab: Settings → CI/CD → Runners → New project runner → copie o token glrt-…
# 2) Na sua máquina (Docker):
docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock gitlab/gitlab-runner:v19.5.3
docker exec -it gitlab-runner gitlab-runner register \
  --non-interactive --url https://gitlab.com --token "glrt-…" \
  --executor docker --docker-image alpine:3.22
```

| Conceito | Detalhe |
|---|---|
| **Executor** | `docker` (recomendado), `shell`, `kubernetes`, `docker-autoscaler`… |
| **Tags** | jobs com `tags: [gpu]` só rodam em runners com a tag `gpu` |
| **Protected** | runner só para jobs de branches/tags protegidas (deploy!) |
| **Token** | os *registration tokens* antigos estão **depreciados e saem no GitLab 20.0**: use o token `glrt-` da tela *New runner* |

> 🔐 Nunca use runner `shell` compartilhado entre projetos de confiança diferente, nem monte o `docker.sock` para projetos públicos: um job poderia controlar a máquina.

## 10. Armadilhas comuns

- **Componente em `@~latest`** em produção: o pipeline muda quando o componente muda.
- **`include: project` sem `ref`**: pega a branch padrão de hoje — e amanhã será outra coisa.
- **Cache de `node_modules/` entre imagens diferentes** (Alpine × Debian): binários incompatíveis.
- **`strategy: depend` esquecido**: o pai fica verde mesmo com o filho vermelho.
- **`extends` e listas**: o merge é profundo para mapas, mas listas (como `script`) são **substituídas**, não somadas — por isso existe o `!reference`.

## 📚 Fontes oficiais

- `parallel:matrix`: <https://docs.gitlab.com/ci/jobs/job_control/#run-a-matrix-of-parallel-trigger-jobs>
- Cache: <https://docs.gitlab.com/ci/caching/>
- Otimizar o YAML (âncoras, `extends`, `!reference`): <https://docs.gitlab.com/ci/yaml/yaml_optimization/>
- `include`: <https://docs.gitlab.com/ci/yaml/includes/>
- Componentes de CI/CD e Catalog: <https://docs.gitlab.com/ci/components/>
- `spec:inputs`: <https://docs.gitlab.com/ci/inputs/>
- Pipelines pai-filho: <https://docs.gitlab.com/ci/pipelines/downstream_pipelines/>
- Ambientes: <https://docs.gitlab.com/ci/environments/>
- ID tokens (OIDC): <https://docs.gitlab.com/ci/secrets/id_token_authentication/>
- GitLab Runner (instalar e registrar): <https://docs.gitlab.com/runner/install/docker/> · <https://docs.gitlab.com/runner/register/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
