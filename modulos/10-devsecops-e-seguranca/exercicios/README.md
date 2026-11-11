# 🏋️ Exercícios — Módulo 10

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 10        # todos do módulo
./ferramentas/corrigir.sh 10 01     # só o exercício 01
```

Os exercícios treinam ligar os scanners, um portão de segurança que funciona no Free e a auditoria de variáveis.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`glab` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta, token ou instância GitLab — e nada é criado de verdade. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — Os scanners no pipeline · `01-ligar-scanners.sh`
Crie `.gitlab-ci.yml` com:
- `stages` contendo `test`;
- `include` dos templates `Jobs/SAST.gitlab-ci.yml`, `Jobs/Secret-Detection.gitlab-ci.yml` e `Jobs/Dependency-Scanning.v2.gitlab-ci.yml` (o **v2**, por SBOM);
- o job `secret_detection` sobrescrito com a variável `SECRET_DETECTION_HISTORIC_SCAN: "true"` (texto).

### 02 — Portão de segurança (funciona no Free) · `02-portao-de-seguranca.sh`
Escreva um script que recebe o caminho de um relatório de segurança do GitLab (formato `gl-*-report.json`, com a lista `.vulnerabilities[]`, cada uma com `severity`, `name` e `location.file`/`location.start_line`):

1. Sem argumento ou arquivo inexistente → **saída 2**.
2. Imprima a contagem por severidade na ordem `Critical`, `High`, `Medium`, `Low`, uma por linha: `Critical: 1`.
3. Para cada vulnerabilidade **Critical** ou **High**, imprima `BLOQUEIA <severidade> <arquivo>:<linha> <nome>`.
4. Saia com **1** se houver alguma Critical/High; **0** caso contrário.

### 03 — Auditoria de variáveis de CI/CD · `03-auditar-variaveis.sh`
Escreva um script que recebe `grupo/projeto` e audita as variáveis com `glab api projects/<codificado>/variables`:

- Uma variável é **sensível** se o nome (`key`) contém `TOKEN`, `SENHA`, `PASSWORD`, `SECRET` ou `KEY`.
- Para cada sensível que **não** seja `masked` **e** `protected` ao mesmo tempo, imprima `RISCO <key>: ` seguido do que falta (`sem máscara`, `não protegida` ou os dois, separados por `, `).
- Variáveis não sensíveis são ignoradas.
- Saída **1** se houver algum risco, **0** se não; **2** sem argumento.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
