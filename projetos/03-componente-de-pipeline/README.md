# Projeto 03 · Componente de pipeline (com verificador)

**Problema:** dez projetos copiam o mesmo job de testes de Node — e cada um já divergiu (Módulo 08). A solução é um **componente de CI/CD** publicado no **CI/CD Catalog**. Só que um erro no componente (uma entrada usada e não declarada, um `default` do tipo errado) só aparece quando **outro** projeto tenta montar o pipeline.

**Solução:** este projeto é o **modelo de um repositório de componente**, pronto para copiar:

| Arquivo | Papel |
|---|---|
| [`templates/testes-node.yml`](templates/testes-node.yml) | o componente: `spec:inputs` (stage, versão do Node, pasta, permitir falha) + o job |
| [`.gitlab-ci.yml`](.gitlab-ci.yml) | o pipeline do próprio projeto: **usa o componente no commit atual** (`@$CI_COMMIT_SHA`), roda o verificador e publica no Catalog a cada tag SemVer |
| [`verificar-componente.sh`](verificar-componente.sh) | o verificador: pega antes do push o que o GitLab só reclamaria depois |

```bash
./projetos/03-componente-de-pipeline/verificar-componente.sh projetos/03-componente-de-pipeline/templates/*.yml
```

```text
✘ templates/x.yml: usa inputs.versao, que não foi declarada
✘ templates/x.yml: entrada 'falha': default 'false' não é boolean
✘ templates/x.yml: imagem em :latest: node:latest
```

**Publicando de verdade**
1. Crie um projeto (ex.: `escola-dev/componentes`), copie `templates/` e `.gitlab-ci.yml` (e o verificador).
2. *Settings → General → Visibility* → ligue **CI/CD Catalog project** e preencha a descrição do projeto.
3. `git tag 1.0.0 && git push --tags` — o job `publicar-no-catalogo` cria a release e o componente aparece em *Explore → CI/CD Catalog*.
4. Quem usa:

```yaml
include:
  - component: $CI_SERVER_FQDN/escola-dev/componentes/testes-node@1.0.0
    inputs:
      versao_node: "24"
```

> ⚠️ `script: [echo $[[ inputs.v ]]]` **quebra o YAML** (os colchetes de `$[[` se confundem com a lista em linha). Use listas em bloco (`- echo …`) sempre que houver `$[[ ]]` — o verificador acusa como “YAML inválido”.

**Conceitos praticados:** componentes e `spec:inputs` (Módulo 08), cache por lockfile (Módulo 08), releases por tag (Módulo 09), imagens com versão fixa (Módulos 07 e 10).

**Desafios para ir além**
1. Um segundo componente `lint-node` no mesmo projeto (cada arquivo em `templates/` é um componente).
2. Faça o verificador checar também `options:` (lista de valores permitidos) e `regex:` das entradas.
3. Adicione um `README.md` do componente com a tabela de entradas **gerada** a partir do `spec` (o Catalog mostra o README).

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · código PolyForm-NC, textos CC BY-NC-SA 4.0</sub>
