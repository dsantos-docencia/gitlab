# Módulo 03 · Issues, labels e boards

> **Você vai sair daqui sabendo:** escrever e triar issues, organizar com labels (inclusive **labels com escopo** `prioridade::alta`), milestones e boards, usar **quick actions** (`/label`, `/assign`, `/estimate`…) para fazer em uma linha o que levaria cinco cliques, criar **templates de descrição** e fechar issues automaticamente pelo merge request — tudo também pelo `glab`.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

O site da loja está no ar e os relatos chegam por todo lado. No GitLab, cada relato vira um **issue** com número (`#12`), dono, prazo e histórico; um **board** mostra o fluxo (A fazer → Fazendo → Revisão → Pronto); e o MR que resolve o problema fecha o issue sozinho.

## 2. Um bom issue

| Parte | Ruim | Bom |
|---|---|---|
| Título | “erro” | “Erro 500 ao salvar perfil com foto acima de 5 MB” |
| Passos | — | 1. Entrar 2. Perfil → Foto 3. Enviar 6 MB 4. Salvar |
| Esperado × obtido | “não funciona” | esperado: aviso “máx. 5 MB”; obtido: erro 500 |
| Ambiente | — | Chrome 140, Android 15, v1.1.0 |

Issues **confidenciais** (`/confidential`) só são vistos por quem tem Reporter ou mais — use para relatos de segurança.

## 3. Organizando

| Ferramenta | Para quê | Exemplo |
|---|---|---|
| **Labels** | categorias, com cor | `~bug`, `~melhoria`, `~"primeira contribuição"` |
| **Labels com escopo** (Premium) | categorias **mutuamente exclusivas**: aplicar uma tira a outra | `~"prioridade::alta"` × `~"prioridade::baixa"`; `~"status::revisão"` |
| **Milestones** | entrega com data | `%v1.1` |
| **Iterations** (Premium) | sprints automáticos | “Sprint 4” |
| **Boards** | colunas por label, responsável ou milestone | A fazer · Fazendo · Pronto |
| **Épicos** (Premium) | agrupar issues de vários projetos | `&3 Checkout novo` |
| **Labels de grupo** | definidos uma vez, valem para todos os projetos do grupo | `escola-dev` → todos |

## 4. Quick actions: comandos dentro do texto

Em qualquer descrição ou comentário, linhas que começam com `/` viram ações:

```text
/label ~bug ~"prioridade::alta"
/assign @bia-dev
/milestone %v1.1
/estimate 3h
/spend 1h30m
/due 2026-11-30
/relate #9
/confidential
/close
```

| Quick action | Efeito |
|---|---|
| `/label` · `/unlabel` · `/relabel` | adiciona · remove · troca labels |
| `/assign @me` · `/unassign` | responsáveis |
| `/milestone` · `/due` | entrega · prazo |
| `/estimate` · `/spend` | controle de tempo |
| `/duplicate #9` | fecha como duplicado e liga os dois |
| `/copy_metadata #9` | copia labels e milestone de outro issue |
| `/close` · `/reopen` | estado |

> 🧠 **Quick actions em templates** são aplicadas quando o issue é criado. Um template `Bug.md` que termina com `/label ~bug` garante que todo bug já nasce rotulado.

## 5. Templates de descrição

Arquivos Markdown em `.gitlab/issue_templates/` aparecem no seletor *Description → Choose a template*:

```markdown
<!-- .gitlab/issue_templates/Bug.md -->
## Passos para reproduzir
1.

## Comportamento esperado

## Comportamento atual

## Ambiente

/label ~bug
/confidential
```

Um template chamado **`Default.md`** é aplicado automaticamente a todo issue novo. O mesmo vale para MRs, em `.gitlab/merge_request_templates/` (Módulo 04).

## 6. Fechando pelo merge request

Na descrição do MR (ou numa mensagem de commit que chega à branch padrão):

```text
Closes #12      Fixes #12      Resolves #12      Implements #12
```

Ao mesclar na **branch padrão**, o issue fecha e fica ligado ao MR. E pelo issue: **Create merge request** cria branch + MR já ligados (`12-erro-500-perfil`).

## 7. Busca e filtros

Na lista de issues, filtre por `Label`, `Assignee = None`, `Milestone`, `Author`, `My reaction`, ordene por *Last updated*. Pela API/glab:

```bash
glab issue list --label bug --not-assignee --output json
glab issue list --assignee=@me --milestone v1.1
glab issue list --search "erro 500" --in title
glab api 'projects/:fullpath/issues?state=opened&assignee_id=None&labels=bug&order_by=updated_at&sort=asc'
```

## 8. Issues pelo terminal

```bash
glab issue create -t "Erro 500 ao salvar perfil" -d "$(cat relato.md)" -l bug,"prioridade::alta" -a bia-dev -m v1.1
glab issue list --label bug --per-page 50
glab issue view 12 --comments
glab issue update 12 --label "prioridade::alta" --unlabel "prioridade::baixa"
glab issue note 12 -m "Reproduzido na v1.1.0. /label ~confirmado"
glab issue close 12
glab label create --name "prioridade::alta" --color "#d93f0b" --description "Resolver nesta semana"
glab label list --per-page 100
```

## 9. Armadilhas comuns

- **Cor sem `#`**: a API de labels quer `#d93f0b`, não `d93f0b`.
- **Label com espaço sem aspas** numa quick action: `/label ~primeira contribuição` aplica `~primeira`. Use `~"primeira contribuição"`.
- **Labels com escopo no Free**: o `::` funciona como texto, mas a exclusividade é recurso Premium.
- **`Closes #12` em MR para outra branch**: o issue só fecha quando a mudança chega à branch padrão.
- **Dado pessoal em issue público** — e lembre que issue confidencial ainda é visto por Reporters.

## 📚 Fontes oficiais

- Issues: <https://docs.gitlab.com/user/project/issues/>
- Labels (inclusive com escopo): <https://docs.gitlab.com/user/project/labels/>
- Quick actions: <https://docs.gitlab.com/user/project/quick_actions/>
- Templates de descrição: <https://docs.gitlab.com/user/project/description_templates/>
- Fechar issues automaticamente: <https://docs.gitlab.com/user/project/issues/managing_issues/#closing-issues-automatically>
- Issue boards: <https://docs.gitlab.com/user/project/issue_board/>
- Milestones: <https://docs.gitlab.com/user/project/milestones/>
- API de issues: <https://docs.gitlab.com/api/issues/>
- `glab issue` / `glab label`: <https://docs.gitlab.com/cli/issue/>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
