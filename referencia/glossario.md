# 📖 Glossário

| Termo | Original | O que é |
|---|---|---|
| **Projeto** | project | o “repositório” do GitLab: código + issues + MRs + CI/CD + registry + wiki |
| **Grupo / subgrupo** | group / subgroup | pasta de projetos e pessoas; papéis e configurações **herdam** para baixo |
| **Namespace** | namespace | o “dono” de um caminho: um usuário ou um grupo (`escola-dev/backend`) |
| **Papel** | role | nível de acesso: Guest (10), Planner (15), Reporter (20), Developer (30), Maintainer (40), Owner (50) |
| **Merge request (MR)** | merge request | pedido para mesclar uma branch em outra, com revisão e pipeline |
| **Rascunho** | draft | MR ainda não pronto para mesclar (`Draft:` no título ou `/draft`) |
| **Aprovação** | approval | o “de acordo” de um revisor; regras de aprovação exigem quantos e de quem (Premium+) |
| **CODEOWNERS** | code owners | arquivo que diz quem é dono de quais caminhos, com **seções** (`[Seção][2] @dono`) |
| **Quick action** | quick action | comando `/…` num issue, MR ou comentário (`/label ~bug`, `/assign me`) |
| **Label com escopo** | scoped label | `chave::valor` — só um valor por chave no mesmo issue (`prioridade::alta`) |
| **Board** | issue board | quadro kanban com colunas por label, responsável ou milestone |
| **Milestone** | milestone | um marco com data: agrupa issues e MRs de uma entrega |
| **Épico** | epic | agrupa issues de vários projetos (Premium+) |
| **Branch / tag protegida** | protected branch / tag | quem pode fazer push, merge ou criar a tag; com ou sem force push |
| **Fork** | fork | cópia de um projeto no seu namespace, para contribuir por MR |
| **Pipeline** | pipeline | a execução do `.gitlab-ci.yml`: etapas e jobs |
| **Job** | job | uma tarefa do pipeline, rodada por um runner |
| **Etapa** | stage | grupo de jobs que rodam juntos; a próxima espera (a não ser com `needs`) |
| **DAG** | directed acyclic graph | pipeline guiado por `needs`, sem esperar etapas inteiras |
| **Runner** | GitLab Runner | o programa que executa os jobs; **executor** = onde (docker, shell, kubernetes…) |
| **Minutos de computação** | compute minutes | a cota de runners do GitLab.com (400/mês no Free, por namespace de topo) |
| **Artefato** | artifact | arquivo que um job entrega para os seguintes (ou para download) |
| **Cache** | cache | arquivos reaproveitados entre pipelines para acelerar (não garantido) |
| **Componente** | CI/CD component | bloco de pipeline versionado com entradas (`spec:inputs`), publicado no **CI/CD Catalog** |
| **Pipeline filho** | child pipeline | pipeline disparado pelo pai a partir de outro arquivo (`trigger:include`) |
| **Ambiente** | environment | destino de implantação (`producao`, `homologacao`) com histórico e rollback |
| **Token do job** | CI_JOB_TOKEN | credencial temporária de cada job; alcance controlado por **allowlist** |
| **ID token** | id_tokens (OIDC) | JWT assinado pelo GitLab para a nuvem trocar por credenciais temporárias |
| **PAT** | personal access token | token pessoal (`glpat-`); há também de projeto, de grupo, deploy (`gldt-`), runner (`glrt-`) |
| **Variável mascarada / protegida / oculta** | masked / protected / hidden | some do log / só em refs protegidas / nem a interface mostra |
| **Release** | release | versão publicada ligada a uma tag, com notas e anexos |
| **Package / Container Registry** | registries | onde o GitLab guarda pacotes (npm, Maven, PyPI, genéricos…) e imagens |
| **Pages** | GitLab Pages | site estático publicado pelo pipeline (`pages: publish: public`) |
| **SAST / DAST** | static / dynamic AST | análise de segurança do código parado / do app rodando |
| **Push protection** | secret push protection | bloqueia o push que contém segredo (Ultimate) |
| **SBOM** | software bill of materials | inventário das dependências (CycloneDX) |
| **Política de segurança** | security policy | regra central que obriga scans/aprovações em vários projetos (Ultimate) |
| **Webhook** | webhook | POST que o GitLab faz para a sua URL a cada evento |
| **Espelho** | mirror | cópia sincronizada de um repositório (push: todos os planos; pull: Premium+) |
| **Self-managed** | self-managed | GitLab instalado por você (Omnibus/Linux package, Docker, Helm) |
| **Paradas obrigatórias** | required upgrade stops | versões pelas quais uma atualização **precisa** passar |
| **GLFM** | GitLab Flavored Markdown | o Markdown do GitLab, com referências (`#12`, `!7`, `~bug`) e extras |

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · CC BY-NC-SA 4.0</sub>
