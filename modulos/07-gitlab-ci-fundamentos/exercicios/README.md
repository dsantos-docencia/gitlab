# 🏋️ Exercícios — Módulo 07

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 07        # todos do módulo
./ferramentas/corrigir.sh 07 01     # só o exercício 01
```

Os exercícios treinam um pipeline correto e sem duplicação, um script de job que conversa com o pipeline e um pipeline agendado/manual.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Um pipeline correto e sem duplicação · `01-pipeline-basico.sh`
Crie `.gitlab-ci.yml` com:
- `workflow:rules` com, nesta ordem: pipeline de MR (`$CI_PIPELINE_SOURCE == "merge_request_event"`); branch **com MR aberto** → `when: never` (`$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS`); qualquer branch (`$CI_COMMIT_BRANCH`);
- `stages: [build, test]`;
- `default` com `image` de **versão fixa** (com `:` e sem `:latest`), `interruptible: true` e `timeout`;
- job `compilar` (stage `build`) com `script` e `artifacts.paths` contendo `dist/` e `artifacts.expire_in`;
- job `testes` (stage `test`) com `needs: [compilar]` e um `script` que rode `./testes.sh`.

O corretor valida contra o **schema oficial** do GitLab CI.

### 02 — Um job que conversa com o pipeline · `02-job-de-versao.sh`
Escreva o script de um job. Ele lê `VERSION` e:
- se **não** for SemVer (`X.Y.Z` com sufixo opcional `-algo`) ou o arquivo não existir: `ERRO: versão inválida: <valor>` em **stderr**, saída **1**, e **não** cria `build.env`;
- senão, cria `build.env` (para `artifacts:reports:dotenv`) com exatamente as linhas `VERSAO=<valor>` e `PRERELEASE=true|false`;
- e envolve o trabalho numa **seção recolhível** chamada `versao`: imprime uma linha contendo `section_start:<timestamp>:versao` no começo e uma contendo `section_end:<timestamp>:versao` no fim.

### 03 — Pipeline agendado e manual · `03-pipeline-agendado.sh`
Crie `.gitlab-ci.yml` com:
- `variables.DIAS` no formato com `value: "7"` (texto) e uma `description` — assim o valor aparece pré-preenchido no formulário *Run pipeline*;
- um job `relatorio` com `image` de versão fixa e `rules` que o incluam **só** quando `$CI_PIPELINE_SOURCE == "schedule"` **ou** `$CI_PIPELINE_SOURCE == "web"` (duas regras);
- um `script` que use a variável **entre aspas duplas** (`"$DIAS"`).

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
