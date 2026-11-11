# Módulo 09 · Releases, pacotes, registry e Pages

> **Você vai sair daqui sabendo:** gerar **changelog** a partir dos commits pela API, publicar **releases** a partir de uma tag (pela palavra-chave `release` e pelo `glab`), guardar binários no **Package Registry**, publicar imagens no **Container Registry** e colocar um site no ar com o **GitLab Pages**.

⏱ 4 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

A Loja tem tags `v1.0.0` e `v1.1.0`, mas ninguém sabe o que mudou entre elas: as “notas de versão” são escritas à mão na sexta à noite. O binário vai por e-mail, a imagem Docker fica no laptop de alguém, e a documentação é um PDF. Vamos fazer **a tag virar tudo isso automaticamente**.

## 2. Versão semântica e tags

`MAIOR.MENOR.CORREÇÃO` — `2.0.0` quebra compatibilidade, `1.3.0` adiciona recurso, `1.2.1` corrige. Releases no GitLab são **sempre ligadas a uma tag**; proteja `v*` (Módulo 06) para que só Maintainers criem versões.

## 3. Changelog gerado pelos commits

O GitLab monta o changelog a partir de **trailers** nos commits:

```text
Corrige timeout no checkout

Changelog: fixed
```

Categorias padrão: `added`, `fixed`, `changed`, `deprecated`, `removed`, `security`, `performance`, `other`.

```bash
# Só gerar o texto (GET) — não altera nada:
glab api "projects/escola-dev%2Floja/repository/changelog?version=1.2.0" | jq -r .notes
# Gravar no CHANGELOG.md com um commit (POST):
glab api -X POST "projects/escola-dev%2Floja/repository/changelog" -f version=1.2.0
glab changelog generate --version 1.2.0         # atalho do glab
```

O intervalo vai da tag anterior (pelo formato SemVer) até o commit atual. Personalize em `.gitlab/changelog_config.yml`.

## 4. Release: duas formas

**a) Palavra-chave `release` no pipeline** — o mais comum:

```yaml
release:
  stage: deploy
  image: registry.gitlab.com/gitlab-org/cli:latest   # contém o glab (fixe por digest em produção)
  rules:
    - if: $CI_COMMIT_TAG
  script: [echo "publicando $CI_COMMIT_TAG"]
  release:
    tag_name: $CI_COMMIT_TAG
    name: Versão $CI_COMMIT_TAG
    description: ./NOTAS.md                          # texto ou caminho de arquivo
    assets:
      links:
        - name: loja-linux-amd64
          url: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/loja/${CI_COMMIT_TAG}/loja-linux-amd64
          link_type: package
```

> ⚠️ A imagem antiga `release-cli` está **depreciada desde o GitLab 18.0 e sai no 20.0**. Use `registry.gitlab.com/gitlab-org/cli`.

**b) `glab release`** — de qualquer lugar:

```bash
glab release create v1.2.0 --notes-file NOTAS.md --ref main
glab release create v1.2.0 ./dist/loja.tar.gz --name "Versão 1.2.0"   # com anexo
glab release list · glab release view v1.2.0 · glab release download v1.2.0
```

| Ideia | Detalhe |
|---|---|
| **Permalink** | `…/-/releases/permalink/latest` aponta sempre para a última |
| **Evidência** | cada release guarda um JSON-snapshot (o que estava na release) |
| **Upcoming** | `released_at` no futuro = release agendada |

## 5. Package Registry

O GitLab hospeda pacotes **npm, Maven, PyPI, NuGet, Composer, Conan, Helm, Go, Terraform** e **genéricos** (qualquer arquivo).

```bash
# Dentro do pipeline: o CI_JOB_TOKEN autentica, sem segredo extra
curl --fail-with-body --header "JOB-TOKEN: $CI_JOB_TOKEN" \
     --upload-file dist/loja.tar.gz \
     "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/generic/loja/1.2.0/loja.tar.gz"
```

Fora do pipeline: `PRIVATE-TOKEN: glpat-…` (escopo `api`) ou um **deploy token** (`gldt-…`, escopos `read_package_registry`/`write_package_registry`).

## 6. Container Registry

Cada projeto tem `registry.gitlab.com/<grupo>/<projeto>`. No pipeline:

```yaml
imagem:
  image: docker:29
  services: [docker:29-dind]
  script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login -u "$CI_REGISTRY_USER" --password-stdin "$CI_REGISTRY"
    - docker build -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" .
    - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"
```

- `--password-stdin` evita a senha na lista de processos.
- **Políticas de limpeza** (*Settings → Packages and registries*) apagam tags antigas — sem elas o armazenamento só cresce (e o Free tem 10 GiB).
- O **Kaniko** (muito usado em tutoriais antigos) foi **arquivado** pelo Google em 2025; prefira Docker-in-Docker, **Buildah** ou o runner com BuildKit.

## 7. GitLab Pages

Site estático servido pelo GitLab, com HTTPS:

```yaml
site:
  image: python:3.13-alpine
  script:
    - pip install mkdocs-material && mkdocs build --site-dir public
  pages:
    publish: public                     # a pasta que vira o site
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

- Desde o 17.9 qualquer job vira o job de Pages com a palavra-chave `pages:`; o antigo `publish` no topo do job foi depreciado.
- URL padrão: `https://<grupo>.gitlab.io/<projeto>` (ou domínio próprio com certificado automático Let's Encrypt).
- **Parallel deployments** (Premium): `pages.path_prefix: $CI_COMMIT_REF_SLUG` publica uma prévia por branch.
- **Controle de acesso**: em projetos privados, só membros veem o site.

## 8. Armadilhas comuns

- **Notas na criação da tag pela interface**: cria a release antes do pipeline, e o job de release falha (“já existe”).
- **Release fora de `rules: if: $CI_COMMIT_TAG`**: roda em todo push e falha sem tag.
- **Imagem `:latest` sem limpeza**: o registry enche e você não sabe qual imagem está em produção.
- **Pages publicado de qualquer branch**: um MR sobrescreve o site oficial.

## 📚 Fontes oficiais

- Releases: <https://docs.gitlab.com/user/project/releases/>
- Exemplos de release no CI/CD: <https://docs.gitlab.com/user/project/releases/release_cicd_examples/>
- release-cli (depreciado) → glab: <https://docs.gitlab.com/user/project/releases/release_cli/>
- Changelogs: <https://docs.gitlab.com/user/project/changelogs/>
- API de repositório (changelog): <https://docs.gitlab.com/api/repositories/#generate-changelog-data>
- Package Registry: <https://docs.gitlab.com/user/packages/package_registry/>
- Pacotes genéricos: <https://docs.gitlab.com/user/packages/generic_packages/>
- Container Registry: <https://docs.gitlab.com/user/packages/container_registry/>
- Construir imagens no CI: <https://docs.gitlab.com/ci/docker/using_docker_build/>
- GitLab Pages: <https://docs.gitlab.com/user/project/pages/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
