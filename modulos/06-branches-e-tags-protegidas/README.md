# Módulo 06 · Branches e tags protegidas

> **Você vai sair daqui sabendo:** proteger branches no GitLab escolhendo **quem pode fazer push e quem pode mesclar**, bloquear force push, exigir aprovação de code owners, proteger **tags** de versão, usar as **regras de merge** do projeto (pipeline verde, threads resolvidas) e o que os planos pagos acrescentam (push rules, aprovações obrigatórias) — aplicando tudo como código pela API.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

Mesmo problema do curso de GitHub — alguém dá push direto na `main`, força o push, apaga a tag `v1.0.0` — e mesma solução, com outro desenho: no GitLab, a proteção é organizada por **papel**: *quem pode fazer push* e *quem pode mesclar*.

## 2. Branch protegida

*Settings → Repository → Protected branches* — por padrão, a branch padrão já nasce protegida (*Maintainers* fazem push e merge).

| Opção | Valores | Recomendação para a `main` |
|---|---|---|
| **Allowed to push and merge** | No one (0) · Developers + Maintainers (30) · Maintainers (40) | **No one** — toda mudança entra por MR |
| **Allowed to merge** | idem | **Developers + Maintainers** (ou Maintainers) |
| **Allowed to force push** | sim/não | **não** |
| **Require approval from code owners** (Premium) | sim/não | sim, em projetos com CODEOWNERS |

- Curingas: `release/*` protege todas as branches de release.
- Usuários e grupos específicos (em vez de papéis) e *deploy keys* com push são recursos de planos pagos.
- No grupo: *Settings → Repository → Default branch* define a proteção padrão para projetos novos.

> 🧠 **“No one” pode dar push, e mesmo assim tudo funciona?** Sim: o merge de um MR é feito **pelo GitLab**, em nome de quem tem permissão de *merge*. Push direto fica impossível; o caminho é sempre o MR — com pipeline, revisão e registro.

## 3. Regras de merge do projeto (todas as branches de destino)

*Settings → Merge requests → Merge checks* (Módulo 02):

| Regra | Campo da API |
|---|---|
| Pipeline precisa ter sucesso | `only_allow_merge_if_pipeline_succeeds` |
| Pipelines pulados contam como sucesso? | `allow_merge_on_skipped_pipeline` (deixe **false**) |
| Todas as threads resolvidas | `only_allow_merge_if_all_discussions_are_resolved` |

## 4. Tags protegidas

`v*` protegida = só quem você escolher cria tags de versão — e ninguém apaga ou move uma tag publicada (nem via push).

```bash
glab api -X POST "projects/:id/protected_tags" -f name='v*' -F create_access_level=40
```

## 5. O que os planos pagos acrescentam

| Recurso | Plano | Para quê |
|---|---|---|
| **Approval rules** | Premium | N aprovações obrigatórias, por grupo de revisores |
| **Code owner approval** na branch protegida | Premium | a seção do CODEOWNERS precisa aprovar |
| **Push rules** | Premium | recusar commits sem assinatura, com e-mail fora do domínio, mensagem fora do padrão, arquivos `.exe`, segredos |
| **Merge trains** | Premium | fila que testa MRs combinados antes de mesclar |
| **Status checks externos** | Ultimate | um sistema de fora aprova/reprova o MR |

No Free, a combinação **branch protegida (push: No one) + pipeline obrigatório + threads resolvidas** já garante que nada entra na `main` sem MR e CI verde.

## 6. Proteção como código (API)

```bash
P=$(jq -rn --arg v "escola-dev/loja" '$v|@uri')        # escola-dev%2Floja
glab api "projects/$P/protected_branches"                                 # listar
glab api "projects/$P/protected_branches/main"                            # detalhes
glab api -X POST "projects/$P/protected_branches" -f name=main \
  -F push_access_level=0 -F merge_access_level=30 -F allow_force_push=false
glab api -X PATCH "projects/$P/protected_branches/main" -F allow_force_push=false
glab api -X DELETE "projects/$P/protected_branches/main"                  # desproteger
glab api -X POST "projects/$P/protected_tags" -f name='v*' -F create_access_level=40
```

> ⚠️ **Proteger de novo dá erro 409** (já existe). Para mudar os níveis de acesso, o caminho mais simples é **desproteger e proteger de novo** (`DELETE` + `POST`) — o que os exercícios fazem de forma idempotente. E nomes com caracteres especiais vão **codificados** na URL: a tag `v*` vira `v%2A`.

## 7. O que um push recusado parece

```text
remote: GitLab: You are not allowed to push code to protected branches on this project.
 ! [remote rejected] main -> main (pre-receive hook declined)

remote: GitLab: You are not allowed to force push code to a protected branch on this project.
```

O exemplo 03 reproduz isso **localmente** com um hook `pre-receive` — o mesmo mecanismo (com o nome que aparece na mensagem!) que o GitLab usa por baixo.

## 8. Armadilhas comuns

- **Push: Maintainers** na `main` “porque sempre foi assim” — Maintainers continuam pulando o MR.
- **Pipeline obrigatório com `allow_merge_on_skipped_pipeline: true`** — um `[ci skip]` e a regra cai.
- **Esquecer as tags**: qualquer Developer apaga `v1.0.0`.
- **Proteger `release/*` e esquecer de criar a primeira** com o papel certo: ninguém consegue criar a branch.
- **Mudar a branch padrão** e esquecer de proteger a nova.

## 📚 Fontes oficiais

- Branches protegidas: <https://docs.gitlab.com/user/project/repository/branches/protected/>
- Proteção padrão da branch padrão: <https://docs.gitlab.com/user/project/repository/branches/default/#protect-initial-default-branches>
- Tags protegidas: <https://docs.gitlab.com/user/project/protected_tags/>
- Merge checks (pipeline, threads): <https://docs.gitlab.com/user/project/merge_requests/auto_merge/>
- Push rules (Premium): <https://docs.gitlab.com/user/project/repository/push_rules/>
- Regras de aprovação (Premium): <https://docs.gitlab.com/user/project/merge_requests/approvals/rules/>
- API de branches protegidas: <https://docs.gitlab.com/api/protected_branches/>
- API de tags protegidas: <https://docs.gitlab.com/api/protected_tags/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
