# 🔐 Checklist de segurança

Para revisar ao criar um projeto e, depois, a cada trimestre. Os itens com **⚙️** o [auditor de projeto](../projetos/02-auditor-de-projeto/) confere sozinho.

## Conta (Módulo 01)
- [ ] Dois fatores ligados (app autenticador ou passkey/WebAuthn) e **códigos de recuperação** guardados fora do computador
- [ ] E-mail de commit **privado** (`ID-usuario@users.noreply.gitlab.com`)
- [ ] Chaves SSH `ed25519`, com **data de validade**, uma por máquina; as antigas removidas
- [ ] Tokens pessoais com **escopo mínimo** (`read_api` > `api`) e **validade**; nenhum sem uso há 90 dias
- [ ] Commits assinados (SSH ou GPG) se o projeto exige — *Verified* no GitLab

## Projeto e grupo (Módulos 02, 04 e 06)
- [ ] Visibilidade correta (privado por padrão); grupo com *Default visibility* e *Prevent forking outside the group* quando cabível
- [ ] ⚙️ Branch padrão **protegida**: push só Maintainers (ou ninguém), merge Developers+, **sem force push**
- [ ] ⚙️ Tags `v*` protegidas (só Maintainers criam versões)
- [ ] ⚙️ Merge só com **pipeline verde** e **discussões resolvidas**
- [ ] Aprovações mínimas e **CODEOWNERS** com aprovação obrigatória na branch protegida (Premium+)
- [ ] ⚙️ No máximo 1–2 pessoas Maintainer+; acessos com **data de expiração** para temporários
- [ ] Membros revisados (`scripts/auditoria/revisar-acessos.sh`): ex-integrantes removidos, contas bloqueadas sem acesso

## CI/CD (Módulos 07, 08 e 10)
- [ ] Imagens com **versão fixa** (idealmente digest `@sha256:`), nunca `:latest`
- [ ] `include: project` com `ref:` e componentes com versão (`@1.2.0`), nunca `@~latest`
- [ ] ⚙️ Variáveis sensíveis **Masked + Protected** (e *Hidden* quando possível), com escopo de ambiente
- [ ] Nada de segredo escrito no `.gitlab-ci.yml`; `CI_DEBUG_TRACE` nunca ligado em produção
- [ ] Deploy por **OIDC** (`id_tokens`) em vez de chave fixa da nuvem
- [ ] ⚙️ Token do job restrito à **allowlist**
- [ ] Runners de deploy **protegidos** e com tags; nenhum runner `shell` compartilhado; `docker.sock` nunca em projeto público
- [ ] Scanners ligados: SAST, segredos, dependências (`.v2`), contêiner; um **portão** que falha com Critical/High
- [ ] `resource_group` nos jobs de deploy; produção com `when: manual` ou ambiente protegido
- [ ] `scripts/auditoria/auditar-pipeline.sh` sem achados

## Integrações e dados (Módulos 09 e 11)
- [ ] ⚙️ Webhooks com **token secreto** e HTTPS com verificação de SSL; nenhum desativado esquecido
- [ ] Robôs usam **token de projeto/grupo** ou service account — nunca o PAT de uma pessoa
- [ ] Políticas de limpeza no Container Registry; pipelines antigos limpos (`scripts/ci/limpar-pipelines.sh`)
- [ ] Self-managed: `gitlab-backup create` agendado **e** `gitlab-secrets.json` + `gitlab.rb` guardados à parte; restauração testada
- [ ] Self-managed: versão dentro do suporte, atualizações seguindo as **paradas obrigatórias**

## Se algo vazou
1. **Revogue** (token, chave) — antes de qualquer outra coisa.
2. Gere um novo e guarde como variável mascarada e protegida (ou cofre/OIDC).
3. Veja o que o segredo acessou (*Audit events*, logs da nuvem).
4. Só então limpe o histórico (`git filter-repo`) e peça que todos reclonem.

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · CC BY-NC-SA 4.0</sub>
