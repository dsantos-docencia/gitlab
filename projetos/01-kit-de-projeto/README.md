# Projeto 01 · Kit de projeto

**Problema:** todo projeto novo da Escola Dev começa “cru”: sem template de issue, sem CODEOWNERS, com a `main` aceitando push direto, e com cada um inventando o seu `.gitlab-ci.yml`. Configurar tudo à mão leva uma hora — e sempre esquece alguma coisa.

**Solução:** [`kit.sh`](kit.sh) deixa o projeto **pronto para time** em um comando, e pode rodar de novo sem estragar nada (é **idempotente**):

```bash
cd ~/codigo/loja
../gitlab/projetos/01-kit-de-projeto/kit.sh escola-dev/loja            # arquivos + configurações
../gitlab/projetos/01-kit-de-projeto/kit.sh escola-dev/loja --sem-api  # só os arquivos
git add .gitlab .gitlab-ci.yml && git commit -m "chore: kit do projeto" && git push
```

```text
Arquivos em .
  ✔ criado   .gitlab/issue_templates/Bug.md
  ✔ criado   .gitlab/merge_request_templates/Default.md
  ✔ criado   .gitlab/CODEOWNERS
  • mantido  .gitlab-ci.yml
Configurações de escola-dev/loja
  ✔ merge só com pipeline verde e discussões resolvidas
  ✔ main protegida: push só Maintainers, merge Developers+, sem force push
  ✔ tags v* protegidas (só Maintainers)
```

| O que entra | Módulo |
|---|---|
| Template de issue com quick actions (`/label ~bug`) | 03 |
| Template padrão de MR (`Default.md`, aplicado sozinho) e CODEOWNERS com seções | 04 |
| Proteção da branch padrão (DELETE + POST, porque a API recusa o 2º POST) e das tags `v*` | 06 |
| `workflow:rules` sem pipeline duplicado | 07 |
| Detecção de segredos e SAST | 10 |

**Decisões de projeto**
- Arquivos que já existem são **mantidos** — o kit não apaga o trabalho de ninguém (use `--forcar` conscientemente).
- A branch protegida vem da API (`default_branch`), não é suposta como `main`.
- Testes: [`testes/kit.teste.sh`](testes/kit.teste.sh), com o `glab` simulado.

**Desafios para ir além**
1. Adicione `--grupo`: aplica o kit a **todos** os projetos de um grupo (`glab api --paginate groups/…/projects`).
2. Crie labels padrão (`bug`, `precisa-triagem`, `tipo::recurso`…) com `glab label create`, sem duplicar.
3. Faça o kit abrir um **MR** com os arquivos em vez de exigir o commit manual (`git push -o merge_request.create`, Módulo 04).

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · código PolyForm-NC, textos CC BY-NC-SA 4.0</sub>
