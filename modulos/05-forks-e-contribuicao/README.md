# Módulo 05 · Forks e contribuição

> **Você vai sair daqui sabendo:** contribuir com projetos dos quais você não é membro (fork → branch → MR), manter o fork atualizado, entender como o pipeline roda em MRs vindos de forks (e por que isso importa para a segurança), espelhar repositórios entre servidores e preparar o seu projeto para receber contribuições.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

O próprio GitLab é open source e recebe milhares de contribuições externas por mês — por fork. E o mesmo modelo funciona dentro de empresas: o time de plataforma mantém um projeto; outros times propõem mudanças por fork, sem ganhar escrita no original.

## 2. Fork, branch, MR

```bash
glab repo fork escola-dev/loja --clone      # fork + clone; o glab configura o remoto "upstream"
cd loja && git remote -v                    # origin = seu fork · upstream = original
git switch -c fix/acentuacao
# ... edita, commita ...
git push -u origin fix/acentuacao
glab mr create --target-project escola-dev/loja --source-branch fix/acentuacao --target-branch main --fill
```

- Marque **“Allow commits from members who can merge to the target branch”**: quem mantém o projeto pode ajustar sua branch.
- O fork guarda a ligação com o original (*fork relationship*): o botão **Update fork** traz as novidades.

### Mantendo o fork em dia

```bash
# 1) botão "Update fork" na página do fork
# 2) Git puro
git fetch upstream
git switch main && git merge --ff-only upstream/main
git push origin main
```

## 3. Pipelines em MRs de fork (segurança!)

| Onde o pipeline roda | Variáveis/segredos do projeto original | Quem decide |
|---|---|---|
| **No fork** (padrão) | **não** — usa as do fork | automático |
| **No projeto pai** | **sim** — risco: o código do fork pode ler segredos | um Maintainer do pai dispara *Run pipeline* depois de **revisar o código** |

> 🔐 Nunca rode no projeto pai um pipeline de fork sem ler o que mudou — inclusive o `.gitlab-ci.yml` do fork. Variáveis **protected** só existem em branches protegidas, o que ajuda: um MR de fork não roda em branch protegida do pai.

## 4. Espelhamento (mirroring)

| Tipo | Direção | Plano |
|---|---|---|
| **Push mirror** | GitLab → outro servidor (GitHub, outro GitLab) | Free |
| **Pull mirror** | outro servidor → GitLab | Premium |

```bash
glab api -X POST projects/:fullpath/remote_mirrors -f url="https://github.com/escola-dev/loja.git" \
  -F enabled=true -F only_protected_branches=true
```

> 💡 É assim que muitos projetos open source vivem no GitLab e aparecem também no GitHub (ou o contrário). E é o que permite rodar **este** curso nos dois: o repositório tem `.github/workflows/` **e** `.gitlab-ci.yml`.

## 5. Preparando o seu projeto para contribuições

O GitLab procura arquivos na **raiz**, em `docs/` e (templates) em `.gitlab/`:

| Arquivo | Para quê |
|---|---|
| `README.md` | o que é, como usar |
| `LICENSE` | o que outros podem fazer (detectada e mostrada na página do projeto) |
| `CONTRIBUTING.md` | como contribuir (linkado no formulário de MR) |
| `CHANGELOG.md` | o que mudou em cada versão (badge na página; Módulo 09 gera pela API) |
| `SECURITY.md` | como relatar vulnerabilidades em privado |
| `.gitlab/issue_templates/` · `.gitlab/merge_request_templates/` | relatos e MRs completos (Módulos 03–04) |

### Licença pela API (com os campos já preenchidos)

Diferente do GitHub, a API de templates do GitLab **preenche** ano, nome e projeto:

```bash
glab api "templates/licenses/mit?project=Loja%20do%20Bairro&fullname=Ana%20Dev" | jq -r .content > LICENSE
```

## 6. Etiqueta

Procure antes de abrir issue; para mudanças grandes, **pergunte antes de programar**; MRs pequenos e focados; responda às revisões; aceite que o mantenedor pode dizer não. Muitos projetos marcam tarefas para iniciantes com labels como `~"good first issue"` ou `~"Seeking community contributions"` (o do próprio GitLab).

## 7. Armadilhas comuns

- **Trabalhar na `main` do fork** — use uma branch por contribuição.
- **Fork de projeto privado**: herda a visibilidade; perde o acesso se você sair do grupo.
- **Esquecer de codificar** espaços nos parâmetros da URL (`fullname=Ana Dev` quebra; `Ana%20Dev` funciona).
- **Rodar pipeline de fork no pai sem revisão** (seção 3).

## 📚 Fontes oficiais

- Forks: <https://docs.gitlab.com/user/project/repository/forking_workflow/>
- Pipelines em MRs de fork: <https://docs.gitlab.com/ci/pipelines/merge_request_pipelines/#use-with-forked-projects>
- Espelhamento de repositório: <https://docs.gitlab.com/user/project/repository/mirror/>
- Templates de licença (API): <https://docs.gitlab.com/api/templates/licenses/>
- Contribuindo com o GitLab: <https://docs.gitlab.com/development/contributing/>
- Guia open source (como contribuir): <https://opensource.guide/pt/how-to-contribute/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
