# 🧪 Laboratório do Curso de GitLab

Há cinco jeitos de praticar. Os exercícios funcionam em **todos** (o corretor usa o `glab` simulado); os exemplos marcados com `GLAB_REAL=1` ficam muito mais interessantes num **GitLab de verdade** — o GitLab.com ou o seu próprio, rodando no notebook.

| Opção | Precisa de | Para quê |
|---|---|---|
| [A — GitLab.com](#opção-a--gitlabcom-recomendado-para-começar) | conta gratuita, `glab` | o fluxo real: issues, MRs, pipelines, registry, Pages |
| [B — Offline, na sua máquina](#opção-b--offline-na-sua-máquina) | Bash, Git, `jq`, `python3` | exercícios e exemplos simulados, sem internet |
| [C — O seu GitLab local (CE + Runner)](#opção-c--o-seu-gitlab-local-ce--runner) | Docker, 4–8 GB de RAM | ser **admin**: runners, backup, atualização, system hooks (Módulos 08 e 11) |
| [D — Container do curso](#opção-d--container-do-curso-docker) | Docker | ambiente idêntico ao do professor, com `glab` e `check-jsonschema` |
| [E — Validar e rodar pipelines localmente](#opção-e--validar-e-rodar-pipelines-localmente) | `check-jsonschema` / `glab` | pegar erro de `.gitlab-ci.yml` antes do push |

Comece conferindo o que você já tem:

```bash
./laboratorio/verificar-ambiente.sh
```

---

## Opção A — GitLab.com (recomendado para começar)

### 1. Crie a conta
Acesse <https://gitlab.com/users/sign_up>. O **nome de usuário** aparece em tudo (`gitlab.com/seu-usuario`) — escolha um nome profissional. Para usar os **runners compartilhados** (os 400 minutos mensais do plano Free), o GitLab.com pode pedir uma **verificação de identidade** (telefone ou cartão, sem cobrança) — é a defesa deles contra mineração de criptomoedas. Prefere não verificar? Use o seu próprio runner (Módulo 08) ou a opção C.

### 2. Proteja a conta (Módulo 01)
*Preferences → Account*: ative a **autenticação de dois fatores** (app autenticador ou passkey/WebAuthn) e **guarde os códigos de recuperação** fora do computador. Em *Preferences → Profile*, marque **Use a private commit email** e use esse e-mail no `git config user.email`.

### 3. Instale Git e o GitLab CLI (`glab`)

| Sistema | Comandos |
|---|---|
| **Windows** | `winget install --id Git.Git -e` e `winget install glab.glab` · use o **Git Bash** para os scripts do curso |
| **macOS** | `brew install git glab jq` |
| **Debian/Ubuntu** | `sudo apt install git jq python3-yaml` + o `.deb` do `glab` da [página de releases](https://gitlab.com/gitlab-org/cli/-/releases) (confira o `checksums.txt`) |
| **Fedora** | `sudo dnf install git glab jq python3-pyyaml` |

```bash
glab --version        # confira (o curso usa a 1.130)
```

### 4. Faça login com o `glab`

```bash
glab auth login
#  ? What GitLab instance do you want to sign in to?   gitlab.com
#  ? How would you like to sign in?                     Web   (OAuth no navegador)
#  ? Choose default Git protocol                        SSH   (ou HTTPS)
#  ? Authenticate Git with your GitLab credentials?     Yes   (se escolheu HTTPS)
glab auth status
```

Prefere token? Crie um **PAT** com escopos `api` e `write_repository` e **data de validade** (Módulo 01), e use `glab auth login --stdin < token.txt`.

### 5. Crie o seu projeto de laboratório

```bash
./laboratorio/criar-lab.sh              # cria seu-usuario/lab-gitlab (privado)
./laboratorio/criar-lab.sh --simular    # quer ver antes o que ele faz? (offline)
```

O script cria um projeto **privado** com conteúdo fictício — README, CODEOWNERS com seção, template de issue com quick action, um `.gitlab-ci.yml` com `workflow:rules`, 5 labels (inclusive a com escopo `prioridade::alta`) e 4 issues, os mesmos dados que o simulador usa. O commit inicial sai com o seu **e-mail privado** do GitLab (`ID-usuario@users.noreply.gitlab.com`). Por que privado? No GitLab, privado e público têm os mesmos recursos do Free: não há o que ganhar expondo o laboratório.

### 6. Rode os exemplos no GitLab de verdade

```bash
export GLAB_REAL=1 LAB_PROJETO=seu-usuario/lab-gitlab
bash modulos/02-projetos-grupos-e-permissoes/exemplos/02-configuracoes-do-projeto.sh
bash modulos/03-issues-labels-e-boards/exemplos/01-ciclo-de-um-issue.sh   # este CRIA um issue no seu lab
```

Os exemplos só agem sobre `$LAB_PROJETO`. Exemplos que não aceitam `GLAB_REAL` rodam sempre simulados (por exemplo, os que criariam grupos).

### 7. (Opcional) Um grupo de laboratório
Para praticar **grupos, subgrupos, herança de papéis** e CODEOWNERS com `@grupo`, crie um grupo gratuito em *New group* (Módulo 02). Lembre: no GitLab.com, grupos privados do Free têm limite de **5 usuários**. Convide um colega e pratique MRs cruzados: um abre, o outro revisa.

### 8. Ao terminar o curso

```bash
./laboratorio/destruir-lab.sh           # pede confirmação digitando o caminho
```

---

## Opção B — Offline, na sua máquina

Precisa só de **Bash, Git, `jq` e `python3` com PyYAML**. Todos os exercícios e todos os exemplos rodam assim: o `glab` simulado ([`ferramentas/simulador/glab`](../ferramentas/simulador/glab)) responde no lugar do GitLab.

```bash
bash modulos/04-merge-requests-e-code-review/exemplos/01-mr-por-push-options.sh
./ferramentas/corrigir.sh 04
```

Curioso para ver o simulador por dentro? Ele tem ~100 linhas comentadas, e as respostas são JSONs legíveis em [`ferramentas/simulador/respostas/`](../ferramentas/simulador/respostas/), escolhidos pelos padrões de [`mapa.tsv`](../ferramentas/simulador/mapa.tsv). Modificar uma resposta e ver o exemplo mudar é um ótimo exercício de `jq`.

---

## Opção C — O seu GitLab local (CE + Runner)

No GitLab.com você nunca é **administrador**. Aqui é: crie runners de instância, veja *Admin Area*, faça backup e restauração, teste uma atualização. Tudo num [`docker-compose.yml`](gitlab-local/docker-compose.yml) com versões fixas (GitLab CE **19.5.4** e Runner **19.5.3**) e um perfil de memória enxuto.

```bash
./laboratorio/gitlab-local.sh subir     # 3–6 min na 1ª vez; depois ~1 min
./laboratorio/gitlab-local.sh senha     # senha inicial do root (o arquivo é apagado em 24 h!)
```

1. Abra <http://localhost:8080>, entre como `root`, **troque a senha** e crie um usuário comum para você (não trabalhe como root — Módulo 02).
2. *Admin → CI/CD → Runners → New instance runner* → marque **Run untagged jobs** → copie o token `glrt-…`.
3. Registre o runner (é o fluxo novo: os *registration tokens* antigos saem no GitLab 20.0):

```bash
./laboratorio/gitlab-local.sh runner glrt-xxxxxxxxxxxxxxxxxxxx
```

4. Faça login do `glab` na sua instância e crie o laboratório nela:

```bash
glab auth login --hostname localhost:8080 --api-protocol http   # use um PAT do SEU usuário
GITLAB_HOST=http://localhost:8080 ./laboratorio/criar-lab.sh
export GLAB_REAL=1 GITLAB_HOST=http://localhost:8080 LAB_PROJETO=seu-usuario/lab-gitlab
```

| Atalho | Faz |
|---|---|
| `gitlab-local.sh backup` | `gitlab-backup create` + lembrete de copiar o `gitlab-secrets.json` (Módulo 11) |
| `gitlab-local.sh status` / `logs` | `gitlab-ctl status` e os logs ao vivo |
| `gitlab-local.sh parar` | para os containers (os dados ficam nos volumes) |
| `gitlab-local.sh apagar` | remove containers **e** volumes (pede confirmação) |

> ⚠️ **Só para estudo:** a porta é ligada a `127.0.0.1` (ninguém da rede acessa), não há HTTPS, e o runner monta o `docker.sock` — o que daria controle da máquina a qualquer job. Nunca reproduza isso num servidor compartilhado (Módulos 08 e 10).

**Exercício de admin (Módulo 11):** faça um backup, apague um projeto, restaure, e confira que ele voltou. Depois, troque a tag da imagem por uma versão mais nova **respeitando as paradas obrigatórias** do [Upgrade Path tool](https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/).

---

## Opção D — Container do curso (Docker)

```bash
./laboratorio/entrar.sh                                # constrói a imagem na 1ª vez e abre um terminal
GITLAB_TOKEN=glpat-… ./laboratorio/entrar.sh           # repassa um token para usar GLAB_REAL=1 lá dentro
```

A imagem ([Dockerfile](Dockerfile)) traz Git, **`glab`** (release oficial, versão fixa, checksum conferido), `jq`, PyYAML, ShellCheck, Bats e **`check-jsonschema`**. Para a garantia total, fixe você mesmo o SHA-256 do `glab` com `--build-arg GLAB_SHA256=…` — a mesma disciplina que o Módulo 10 ensina para imagens e componentes.

---

## Opção E — Validar e rodar pipelines localmente

| Ferramenta | O que faz | Comando |
|---|---|---|
| **`check-jsonschema`** | valida o `.gitlab-ci.yml` contra o **schema oficial**, offline (é o que o corretor do curso usa) | `check-jsonschema --builtin-schema vendor.gitlab-ci .gitlab-ci.yml` |
| **`glab ci lint`** | pede ao **seu GitLab** para validar — resolve `include`, `extends` e componentes | `glab ci lint` |
| **Pipeline editor** | *Build → Pipeline editor*: validação ao vivo e a aba **Full configuration** com tudo expandido | — |
| **`gitlab-ci-local`** (comunidade) | roda jobs do `.gitlab-ci.yml` em Docker na sua máquina | `gitlab-ci-local --list` · `gitlab-ci-local testes` |

Limitações honestas: o schema não sabe se um `include: project` existe nem resolve `!reference`; o `gitlab-ci-local` **não é oficial** e não reproduz tudo (componentes, OIDC, ambientes protegidos). Use as ferramentas locais para pegar erros cedo; a palavra final é sempre um pipeline de verdade.

---

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| `glab: command not found` | glab não instalado | passo 3 da opção A |
| `401 Unauthorized` | token expirou ou foi revogado | `glab auth login` de novo |
| `404 Project Not Found` com o caminho certo | caminho sem codificar (`grupo/projeto` → `grupo%2Fprojeto`) ou sem permissão | `jq -rn --arg v "$p" '$v\|@uri'` (Módulo 11) |
| `403 Forbidden` | papel insuficiente | rode no seu `lab-gitlab`, onde você é Owner |
| pipeline “pending” para sempre | sem runner disponível (ou conta não verificada no GitLab.com) | verifique a conta ou registre um runner (Módulo 08) |
| `ModuleNotFoundError: yaml` | falta PyYAML | `pip install pyyaml` ou `apt install python3-yaml` |
| exemplo com `GLAB_REAL=1` reclama de `LAB_PROJETO` | variável não definida | `export LAB_PROJETO=seu-usuario/lab-gitlab` |
| GitLab local “502” por minutos | ainda iniciando (ou pouca RAM) | `gitlab-local.sh logs`; feche programas; 4 GB livres no mínimo |
| `Permission denied (publickey)` | chave SSH não cadastrada | Módulo 01, seção SSH, ou use HTTPS |

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · CC BY-NC-SA 4.0</sub>
