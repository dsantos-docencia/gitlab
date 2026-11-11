# 🔁 Cheat sheet do GitLab CI/CD (`.gitlab-ci.yml`)

Referência completa: <https://docs.gitlab.com/ci/yaml/>. Valide sempre: `check-jsonschema --builtin-schema vendor.gitlab-ci .gitlab-ci.yml` (offline) ou `glab ci lint` (no seu GitLab).

## Esqueleto recomendado

```yaml
workflow:
  rules:                                        # um pipeline por mudança (nada de branch + MR duplicados)
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
      when: never
    - if: $CI_COMMIT_BRANCH
    - if: $CI_COMMIT_TAG

stages: [build, test, deploy]

default:
  image: alpine:3.22                            # SEMPRE com versão
  interruptible: true                           # push novo cancela o pipeline velho
  retry:
    max: 1
    when: [runner_system_failure, stuck_or_timeout_failure]

variables:
  TZ: America/Sao_Paulo
```

## Palavras-chave globais

| Chave | Para quê |
|---|---|
| `workflow` | se/como o pipeline existe (`rules`, `name`, `auto_cancel`) |
| `stages` | a ordem das etapas (padrão: `.pre build test deploy .post`) |
| `default` | valores herdados por todos os jobs (`image`, `before_script`, `cache`, `retry`, `tags`…) |
| `variables` | variáveis globais (texto!) |
| `include` | `local`, `project` (+ `ref`), `remote`, `template`, `component` |

## Palavras-chave de job

| Chave | Exemplo / nota |
|---|---|
| `stage`, `image`, `services` | `services: [postgres:17]` sobe um banco ao lado |
| `script`, `before_script`, `after_script` | listas de comandos; `after_script` roda mesmo com falha |
| `rules` | `if`, `changes`, `exists`, `when`, `allow_failure`, `variables`, `needs` |
| `needs` | DAG: começa quando as dependências terminam, sem esperar a etapa |
| `artifacts` | `paths`, `expire_in`, `when`, `reports: {junit, dotenv, coverage_report, …}` |
| `cache` | `key` (`files:`, `$CI_COMMIT_REF_SLUG`), `paths`, `policy: pull \| push \| pull-push` |
| `parallel` | `5` (fatias) ou `matrix:` (combinações; total = soma dos produtos) |
| `extends`, `!reference` | reaproveitar (`extends` substitui listas; `!reference` insere pedaços) |
| `environment` | `name`, `url`, `on_stop`, `action`, `deployment_tier` |
| `resource_group` | um job por vez naquele recurso (deploy) |
| `release` | cria release (imagem `registry.gitlab.com/gitlab-org/cli`) |
| `pages` | `publish: public`, `path_prefix`, `expire_in` |
| `trigger` | `include` (filho) ou `project` (multi-projeto) + `strategy: depend` |
| `id_tokens` | JWT OIDC para nuvem/Vault/Sigstore: `aud:` obrigatório |
| `tags` | escolhe o runner (`[docker, gpu]`) |
| `timeout`, `retry`, `interruptible`, `allow_failure` | `allow_failure: {exit_codes: [137]}` |
| `coverage` | regex para extrair a cobertura do log |
| `when` | `on_success` · `on_failure` · `always` · `manual` · `delayed` (+ `start_in`) · `never` |

## Variáveis predefinidas mais usadas

| Variável | Valor |
|---|---|
| `CI_PIPELINE_SOURCE` | `push`, `merge_request_event`, `schedule`, `web`, `api`, `trigger`, `pipeline`, `parent_pipeline` |
| `CI_COMMIT_BRANCH` / `CI_COMMIT_TAG` | branch (vazio em tag e em pipeline de MR) / tag |
| `CI_DEFAULT_BRANCH` | branch padrão do projeto |
| `CI_COMMIT_SHA` / `CI_COMMIT_SHORT_SHA` | commit (40 / 8 caracteres) |
| `CI_COMMIT_REF_SLUG` | ref em formato seguro para URL/DNS (`feature-login`) |
| `CI_MERGE_REQUEST_IID` / `CI_MERGE_REQUEST_TARGET_BRANCH_NAME` | só em pipeline de MR |
| `CI_OPEN_MERGE_REQUESTS` | MRs abertos para esta branch (anti-duplicação) |
| `CI_PROJECT_PATH` / `CI_PROJECT_ID` / `CI_PROJECT_DIR` | caminho, ID, pasta do clone |
| `CI_SERVER_FQDN` / `CI_API_V4_URL` | `gitlab.com` / `https://gitlab.com/api/v4` |
| `CI_REGISTRY`, `CI_REGISTRY_IMAGE`, `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD` | Container Registry |
| `CI_JOB_TOKEN` | token do job (API, registry, pacotes, clone de outros projetos) |
| `CI_ENVIRONMENT_NAME` / `CI_ENVIRONMENT_URL` | quando o job tem `environment` |

## Receitas de `rules`

```yaml
rules:
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH                       # só na padrão
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"                  # só em MR
  - if: $CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+$/                          # só em tag SemVer
  - if: $CI_PIPELINE_SOURCE == "schedule" && $TAREFA == "relatorio"   # agendado específico
  - changes: [frontend/**/*]                                          # só se o frontend mudou
  - exists: [Dockerfile]                                              # só se existe
  - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    when: manual                                                      # botão ▶
  - when: never                                                       # todo o resto: não
```

## Artefatos × cache × dotenv

```yaml
versao:
  script: [echo "VERSAO=1.2.$CI_PIPELINE_IID" >> build.env]
  artifacts:
    reports:
      dotenv: build.env                # VERSAO vira variável nos jobs seguintes
testes:
  script: [npm test -- --reporters=jest-junit]
  artifacts:
    when: always                       # guarda o relatório mesmo se falhar
    reports:
      junit: junit.xml                 # aparece no MR
      coverage_report: {coverage_format: cobertura, path: coverage/cobertura-coverage.xml}
```

## Seções recolhíveis no log

```bash
echo -e "\e[0Ksection_start:$(date +%s):instalar[collapsed=true]\r\e[0KInstalando dependências"
npm ci
echo -e "\e[0Ksection_end:$(date +%s):instalar\r\e[0K"
```

## Templates e componentes úteis

```yaml
include:
  - template: Jobs/SAST.gitlab-ci.yml
  - template: Jobs/Secret-Detection.gitlab-ci.yml
  - template: Jobs/Dependency-Scanning.v2.gitlab-ci.yml
  - template: Jobs/Container-Scanning.gitlab-ci.yml
  - template: Jobs/SAST-IaC.gitlab-ci.yml
  - component: $CI_SERVER_FQDN/grupo/componentes/testes-node@1.2.0   # versão FIXA
    inputs: {versao_node: "24"}
```

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · CC BY-NC-SA 4.0 · Fonte: <https://docs.gitlab.com/ci/></sub>
