# 🏋️ Exercícios — Módulo 09

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 09        # todos do módulo
./ferramentas/corrigir.sh 09 01     # só o exercício 01
```

Os exercícios treinam a palavra-chave `release`, um script de publicação com o `glab` e o GitLab Pages.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Release automática a cada tag · `01-release-por-tag.sh`
Crie `.gitlab-ci.yml` com o job `release`:
- `image` do **glab** (`registry.gitlab.com/gitlab-org/cli…`) — **não** a `release-cli` depreciada;
- só roda em tags: `rules` com `if: $CI_COMMIT_TAG`;
- `release.tag_name: $CI_COMMIT_TAG`, `release.name: Versão $CI_COMMIT_TAG`, `release.description: ./NOTAS.md`;
- um link em `release.assets.links` com `link_type: package` apontando para `…/packages/generic/…`;
- um `script` (obrigatório em todo job).

### 02 — Script de publicação com changelog · `02-publicar-release.sh`
Escreva um script que recebe a **versão** (`1.2.0`) e publica a release `v1.2.0` no projeto da variável `PROJETO` (padrão `aluno/laboratorio`):

1. Versão fora do formato `N.N.N` ou ausente → mensagem no stderr e **saída 2**.
2. Liste as releases (`glab api projects/<projeto codificado>/releases`); se `v<versão>` **já existir** → mensagem e **saída 1**, sem criar nada.
3. Busque as notas com `glab api "projects/<projeto codificado>/repository/changelog?version=<versão>"` (campo `.notes`).
4. Crie: `glab release create v<versão> --notes "<notas>" --ref main -R <projeto>`.

Lembre: `aluno/laboratorio` vira `aluno%2Flaboratorio` na URL.

### 03 — Documentação no GitLab Pages · `03-site-no-pages.sh`
Crie `.gitlab-ci.yml` com o job `documentacao`, que publica um site no Pages:
- `image` de versão fixa (nada de `:latest`);
- `script` que gera `public/index.html`;
- palavra-chave `pages` com `publish: public`;
- só roda na branch padrão: `rules` com `if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH`.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
