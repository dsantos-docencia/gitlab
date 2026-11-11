# Módulo 01 · Conta, segurança e autenticação

> **Você vai sair daqui sabendo:** proteger a conta com 2FA, manter o e-mail privado sem perder a autoria dos commits, autenticar o Git por HTTPS, SSH ou `glab`, escolher entre os **muitos tipos de token** do GitLab (pessoal, de projeto, de grupo, deploy, CI job token…) com o menor escopo possível, reconhecer cada um pelo prefixo e assinar commits.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

No GitLab, uma conta não dá acesso só ao código: dá acesso aos **pipelines** — e pipelines têm segredos de produção, chaves de deploy, acesso à nuvem. Um token vazado de um Maintainer pode alterar o `.gitlab-ci.yml` e exfiltrar tudo. Por isso começamos pela identidade.

## 2. A conta bem configurada

| Item | Onde (avatar → *Edit profile*) | Por quê |
|---|---|---|
| **2FA** (app TOTP ou WebAuthn/chave física) | *Account → Two-Factor Authentication* | senha vazada deixa de bastar |
| **Códigos de recuperação** offline | idem | perder o celular sem eles = suporte demorado |
| **E-mail de commit privado** | *Profile → Commit email → Use a private email* | seu e-mail real não fica em cada commit |
| **Revisar sessões ativas** e **tokens** | *Active sessions* · *Access tokens* | descobrir acesso que você não fez |

### O e-mail privado do GitLab

```
ID-usuario@users.noreply.gitlab.com       ← ID numérico + hífen + usuário
```

```bash
glab api user | jq -r '"\(.id)-\(.username)@users.noreply.gitlab.com"'
git config --global user.email "1234567-aluno@users.noreply.gitlab.com"
```

> 🧠 Repare na diferença para o GitHub (`ID+usuario@users.noreply.github.com`): **hífen** no GitLab, **mais** no GitHub. Errar o separador = commits sem dono.

## 3. Três jeitos de autenticar o Git

| | HTTPS + token | SSH | `glab auth login` |
|---|---|---|---|
| URL | `https://gitlab.com/grupo/projeto.git` | `git@gitlab.com:grupo/projeto.git` | qualquer uma |
| Credencial | usuário + **token** (a senha da conta não serve com 2FA ligado) | par de chaves | token guardado pelo glab |
| Porta 22 bloqueada? | passa (443) | use `altssh.gitlab.com:443` | passa |

```bash
ssh-keygen -t ed25519 -C "voce@exemplo.com"
glab ssh-key add ~/.ssh/id_ed25519.pub --title notebook --usage-type auth
ssh -T git@gitlab.com            # "Welcome to GitLab, @voce!"
```

```sshconfig
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host gitlab-443                  # git@gitlab-443:grupo/projeto.git
    HostName altssh.gitlab.com
    Port 443
    User git
```

```bash
glab auth login                                   # GitLab.com ou --hostname gitlab.empresa.local
glab auth status
glab auth login --stdin < token.txt               # sem prompt (scripts)
```

## 4. Os tokens do GitLab

![Tokens do GitLab](../../assets/tokens-gitlab.svg)

O GitLab tem mais tipos de token que o GitHub — cada um para um caso:

| Token | Prefixo | Use para | Evite |
|---|---|---|---|
| **Pessoal** (PAT) | `glpat-` | scripts seus, `glab`, Git por HTTPS | dar escopo `api` quando `read_repository` basta |
| **De projeto / de grupo** | `glpat-` | automações do time — age como um **usuário-robô**, não como você | usar seu PAT pessoal num servidor compartilhado |
| **Deploy token** | `gldt-` | servidor que só **clona** ou **baixa** pacotes/imagens | — |
| **Deploy key** | (chave SSH) | servidor que clona por SSH (pode ser só leitura) | dar escrita sem necessidade |
| **CI job token** | `glcbt-` | dentro do pipeline: `$CI_JOB_TOKEN`, expira com o job | guardar um PAT como variável de CI quando o job token resolve |
| **Runner** | `glrt-` | registrar um runner (Módulo 08) | versionar o `config.toml` |
| **Gatilho de pipeline** | `glptt-` | disparar pipeline por API (Módulo 11) | colar na URL de um webhook público |
| **Feed** | `glft-` | ler feeds RSS/calendário | — |

**Escopos comuns de PAT:** `read_api` · `api` (tudo!) · `read_repository` · `write_repository` · `read_registry` · `write_registry` · `ai_features`. **Validade** é obrigatória (máximo de 365 dias, por padrão). O GitLab avisa por e-mail antes de expirar.

> 🚨 **Vazou?** Revogue primeiro (*Access tokens → Revoke*), depois investigue. O GitLab.com **revoga automaticamente** tokens `glpat-` encontrados em repositórios públicos (*secret detection* com revogação automática).

## 5. Commits verificados

O GitLab verifica assinaturas **SSH**, **GPG** e **X.509** e mostra o selo **Verified**.

```bash
glab ssh-key add ~/.ssh/id_ed25519.pub --title assinatura --usage-type signing
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

Com **push rules** (Premium), dá para **rejeitar** commits não assinados ou com e-mail que não é de um membro.

## 6. Armadilhas comuns

- **Token na URL do remoto** (`https://oauth2:glpat-…@gitlab.com/…`) — fica em `.git/config` e em `git remote -v`.
- **PAT com escopo `api` e validade de um ano** para um script que só lê.
- **Usar a senha da conta** com 2FA ligado: `HTTP Basic: Access denied`. Use token.
- **Confundir deploy *token* com deploy *key*:** o primeiro é usuário+senha para HTTPS/registry; a segunda é chave SSH.
- **Deixar `$CI_JOB_TOKEN` acessar qualquer projeto**: configure a *allowlist* (Módulo 10).

## 📚 Fontes oficiais

- Autenticação de dois fatores: <https://docs.gitlab.com/user/profile/account/two_factor_authentication/>
- E-mail de commit privado: <https://docs.gitlab.com/user/profile/#use-an-automatically-generated-private-commit-email>
- Usar chaves SSH: <https://docs.gitlab.com/user/ssh/>
- SSH pela porta 443 no GitLab.com: <https://docs.gitlab.com/user/gitlab_com/#alternative-ssh-port>
- Visão geral dos tokens (prefixos): <https://docs.gitlab.com/security/tokens/>
- Tokens de acesso pessoal: <https://docs.gitlab.com/user/profile/personal_access_tokens/>
- Tokens de projeto: <https://docs.gitlab.com/user/project/settings/project_access_tokens/>
- Deploy tokens: <https://docs.gitlab.com/user/project/deploy_tokens/>
- Commits assinados: <https://docs.gitlab.com/user/project/repository/signed_commits/>
- `glab auth`: <https://docs.gitlab.com/cli/auth/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
