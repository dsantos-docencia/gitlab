# 🏋️ Exercícios — Módulo 08

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 08        # todos do módulo
./ferramentas/corrigir.sh 08 01     # só o exercício 01
```

Os exercícios treinam matriz com cache, um componente de CI/CD com entradas e pipelines pai-filho.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Matriz com cache por lockfile · `01-matriz-e-cache.sh`
Crie `.gitlab-ci.yml` com o job `testes`:
- `image: node:$VERSAO_NODE-alpine`;
- `parallel.matrix` com **duas** sub-matrizes: (1) `VERSAO_NODE: ["20","22","24"]` × `BANCO: [postgres, mysql]`; (2) `VERSAO_NODE: "24"` com `BANCO: sqlite` — total de **7 jobs**;
- `cache` com `key.files: [package-lock.json]` e `paths: [.npm/]`;
- `script` com `npm ci --cache .npm` e `npm test`.

### 02 — Um componente de CI/CD e quem o usa · `02-componente-ci.sh`
Crie **dois** arquivos:

**`templates/testes.yml`** (o componente), com dois documentos YAML separados por `---`:
1. `spec.inputs` com `stage` (`default: test`) e `versao_node` (`type: string`, `default: "22"`);
2. um job `testes-node` com `stage: $[[ inputs.stage ]]`, `image: node:$[[ inputs.versao_node ]]-alpine` e `script` com `npm test`.

**`.gitlab-ci.yml`** (quem usa), com `include` de **um** componente `$CI_SERVER_FQDN/escola-dev/componentes/testes@1.2.0` (versão **fixa**) passando `inputs.versao_node: "24"`.

### 03 — Pipeline pai-filho para um monorepo · `03-pai-e-filho.sh`
Crie:

**`.gitlab-ci.yml`** (pai) com o job `frontend` que dispara um **pipeline filho**: `trigger.include: frontend/.gitlab-ci.yml`, `trigger.strategy: depend`, e `rules` com uma regra `changes: [frontend/**/*]`.

**`frontend/.gitlab-ci.yml`** (filho) com um job `testes-frontend` (`image` de versão fixa, `script` qualquer).

Os dois passam no schema oficial.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
