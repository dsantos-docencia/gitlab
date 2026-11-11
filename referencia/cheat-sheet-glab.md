# ⌨️ Cheat sheet do `glab` (GitLab CLI)

Todos os comandos do `glab` usados no curso, por área, com variações. Versão de referência: **glab 1.130**. Ajuda de qualquer comando: `glab <comando> --help`.

> Convenções: `-R grupo/projeto` age em outro projeto (sem ele, o `glab` usa o remoto do diretório atual) · `@me` = você · o `glab` **não tem `--jq`**: use `--output json | jq` ou `glab api … | jq`.

## Autenticação e configuração

```bash
glab auth login                                   # interativo (GitLab.com ou self-managed)
glab auth login --hostname gitlab.empresa.com     # outra instância
glab auth login --stdin < token.txt               # com PAT, sem digitar
glab auth status                                  # quem sou, em quais instâncias
glab config set editor nano                       # editor para descrições
glab config set git_protocol ssh --host gitlab.com
export GITLAB_HOST=http://localhost:8080          # instância padrão desta sessão
export GITLAB_TOKEN=glpat-…                        # token por variável (CI, container)
```

## Projetos

```bash
glab repo create loja --private --description "Loja da Escola Dev"
glab repo create escola-dev/loja --group escola-dev    # dentro de um grupo
glab repo clone escola-dev/loja
glab repo clone -g escola-dev -p --paginate       # o GRUPO inteiro, preservando subgrupos (-p)
glab repo view escola-dev/loja                    # README e metadados
glab repo view --web                              # abre no navegador
glab repo fork escola-dev/loja --clone            # fork + clone + remoto upstream
glab repo list --mine
glab repo archive escola-dev/legado
glab repo delete aluno/lab-gitlab --yes           # cuidado!
```

## Issues

```bash
glab issue create --title "Erro 500 no perfil" --description "…" --label bug,prioridade::alta --assignee @me
glab issue create --title "…" --confidential --milestone v1.1 --yes
glab issue list                                   # abertos
glab issue list --assignee=@me --label bug
glab issue list --closed --search "login" --per-page 50
glab issue list --output json | jq -r '.[] | "#\(.iid) \(.title)"'
glab issue view 12 --comments
glab issue note 12 -m "Reproduzi no Firefox. /label ~precisa-triagem"   # quick actions no comentário
glab issue update 12 --label prioridade::média --unlabel prioridade::alta
glab issue close 12 · glab issue reopen 12
glab issue board view                              # o board no terminal
```

## Labels e variáveis

```bash
glab label list
glab label create --name "prioridade::alta" --color "#b60205" --description "Resolver primeiro"
glab variable list
glab variable set DEPLOY_TOKEN "valor" --masked --protected --scope producao
glab variable get DEPLOY_TOKEN
glab variable delete DEPLOY_TOKEN
glab variable export > variaveis.json             # backup (CUIDADO: valores em texto)
```

## Merge requests

```bash
glab mr create --fill --draft                     # título/descrição dos commits, como rascunho
glab mr create --title "feat: CSV" --target-branch main --label melhoria \
    --reviewer bia-dev --assignee @me --remove-source-branch --squash-before-merge
glab mr create --fill --related-issue 12           # liga ao issue (e cria "Closes #12")
git push -o merge_request.create -o merge_request.target=main      # MR direto do push
glab mr list --reviewer=@me                       # a sua fila de revisão
glab mr list --author=@me --draft
glab mr view 7 --comments
glab mr diff 7
glab mr checkout 7                                # baixa a branch do MR para testar
glab mr note 7 -m "LGTM, só um detalhe na linha 40"
glab mr approve 7 · glab mr revoke 7
glab mr update 7 --ready                          # tira do rascunho
glab mr rebase 7
glab mr merge 7 --auto-merge --squash             # mescla quando o pipeline passar
```

## CI/CD

```bash
glab ci lint                                      # valida no SEU GitLab (resolve include/extends)
glab ci status                                    # pipeline da branch atual
glab ci view                                      # interface interativa (jobs, logs, retry)
glab ci list --status failed
glab ci run -b main --variables AMBIENTE:homologacao   # dispara (CHAVE:VALOR)
glab ci trace testes                              # log ao vivo de um job
glab ci retry 12345                               # um job, pelo ID
glab ci delete 9100                               # apaga um pipeline (logs e artefatos juntos)
glab job artifact main build                      # artefatos do último job "build" da main (versões antigas: glab ci artifact)
glab schedule list · glab schedule run 12
glab schedule create --cron "0 11 * * 1" --ref main --description "Relatório semanal"
```

## Releases e changelog

```bash
glab release create v1.2.0 --notes-file NOTAS.md --ref main
glab release create v1.2.0 ./dist/loja.tar.gz --name "Versão 1.2.0"   # com anexo
glab release list · glab release view v1.2.0
glab release download v1.2.0 --asset-name loja.tar.gz
glab release upload v1.2.0 ./dist/loja-linux.tar.gz
glab changelog generate --version 1.2.0           # pelos trailers "Changelog:" dos commits
```

## API (o canivete suíço)

```bash
glab api user
glab api "projects/escola-dev%2Floja"                       # caminho CODIFICADO (ou o ID)
glab api --paginate "groups/escola-dev/projects?include_subgroups=true&per_page=100"
glab api -X POST "projects/escola-dev%2Floja/issues" -f title="Bug" -f labels=bug
glab api -X PUT  "projects/escola-dev%2Floja" -F only_allow_merge_if_pipeline_succeeds=true
glab api -X DELETE "projects/escola-dev%2Floja/protected_branches/main"
glab api -X POST "projects/escola-dev%2Floja/pipeline" -H 'Content-Type: application/json' --input corpo.json
glab api graphql -f query='query { currentUser { username } }'
jq -rn --arg v "escola-dev/loja" '$v | @uri'                # → escola-dev%2Floja
```

| Opção | Significado |
|---|---|
| `-X MÉTODO` | GET (padrão), POST, PUT, DELETE |
| `-f chave=valor` | campo **texto** |
| `-F chave=valor` | campo **tipado** (`true`, `30`, `null`, `@arquivo`) |
| `-H 'Cabeçalho: valor'` | cabeçalho extra |
| `--input arquivo` / `--input -` | corpo da requisição de um arquivo / da entrada padrão |
| `--paginate` | segue todas as páginas |
| `-i` | mostra cabeçalhos da resposta (`x-total`, `x-next-page`) |

## Chaves e tokens

```bash
glab ssh-key add ~/.ssh/id_ed25519.pub --title "notebook 2026"
glab ssh-key list
glab deploy-key add chave.pub --title "servidor de deploy" --can-push=false
glab token list                                   # tokens pessoais/de projeto
```

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · CC BY-NC-SA 4.0 · Fonte: [documentação do glab](https://gitlab.com/gitlab-org/cli/-/tree/main/docs/source)</sub>
