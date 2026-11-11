# 🤝 Guia de Contribuição

**Junte-se a mim e deixe algo de útil para o próximo.** 🌱 Conhecimento que não é compartilhado morre com quem o guarda. Correções de erros, novos exemplos, exercícios, traduções, scripts da comunidade e melhorias de texto são todos bem-vindos — não importa o tamanho.

## Formas de contribuir

| Quero… | Como |
|---|---|
| **Corrigir um erro** (texto, exemplo, link) | [issue "🐛 Erro"](https://github.com/dsantos-docencia/gitlab/issues/new/choose) ou PR direto |
| **Sugerir um exemplo/exercício** | [issue "💡 Sugestão"](https://github.com/dsantos-docencia/gitlab/issues/new/choose) |
| **Compartilhar um script meu** | [issue "📜 Enviar um script"](https://github.com/dsantos-docencia/gitlab/issues/new/choose) → entra em [`scripts/comunidade/`](scripts/comunidade/) com seu crédito |
| **Traduzir** | veja o [guia de tradução](traducoes/README.md) |

> **Sobre a licença das contribuições:** ao contribuir, você concorda que sua contribuição será publicada sob as licenças do projeto (**uso não comercial** — PolyForm Noncommercial para código, CC BY-NC-SA para conteúdo; veja o [NOTICE](NOTICE.md)), mantendo seu crédito como autor.

## Antes de começar

Este repositório tem uma promessa: **todo código aqui funciona**. Para mantê-la, existe uma verificação automática. Rode-a localmente antes de abrir um Pull Request:

```bash
./ferramentas/verificar-tudo.sh
```

Ela roda:
1. **Sintaxe** (`bash -n`) de todo `.sh`
2. **ShellCheck** (`apt install shellcheck`, `brew install shellcheck` ou [shellcheck.net](https://www.shellcheck.net))
3. **YAML válido** em todo `.yml`, **schema oficial do GitLab CI** nos pipelines (`pip install check-jsonschema`) e **actionlint**/**zizmor** no workflow do próprio repositório
4. **Execução** de todos os exemplos
5. **Soluções** oficiais contra os testes
6. **Testes** dos projetos e dos scripts reais

Se passar localmente, passará no CI — no [GitHub Actions](.github/workflows/verificar.yml) e, num espelho no GitLab, no [`.gitlab-ci.yml`](.gitlab-ci.yml).

## Padrão dos arquivos

### Módulos
```
modulos/NN-nome-do-modulo/
├── README.md                    # teoria: o PORQUÊ antes do COMO
├── exemplos/
│   └── NN-nome.sh               # executável, muito comentado, roda sozinho
└── exercicios/
    ├── README.md                # enunciados
    ├── NN-nome.sh               # esqueleto para o aluno preencher
    ├── solucoes/NN-nome.sh      # solução oficial comentada
    └── testes/NN-nome.teste.sh  # casos de teste (funções teste_*)
```

### Cabeçalho obrigatório em todo `.sh`
```bash
#!/usr/bin/env bash
# ============================================================================
#  Curso de GitLab · Módulo NN · <título>
#  Prof. Daniel Santos · github.com/dsantos-docencia/gitlab · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ...
#  EXECUTE   ...
# ============================================================================
```

### Regras de ouro para exemplos
- **Devem rodar sem argumentos** e sem travar (`stdin` pode ser `/dev/null`).
- **Não podem alterar o sistema**: se precisam criar/apagar arquivos, use `mktemp -d` e `trap '... EXIT'`.
- Comentários explicam o **porquê**, não só o quê.
- Zero avisos do ShellCheck (ou um `# shellcheck disable=SCxxxx` justificado).

### Escrevendo um teste
Toda função `teste_*` em um arquivo `.teste.sh` é descoberta e rodada isoladamente. Os arquivos `.teste.sh` são *sourced* (não executados), então começam com a diretiva `# shellcheck shell=bash` em vez de shebang. As asserções disponíveis estão documentadas em [`ferramentas/lib/teste.sh`](ferramentas/lib/teste.sh):

```bash
# shellcheck shell=bash
teste_descricao_curta() {
    executar arg1 arg2          # roda o script do aluno
    afirmar_status 0
    afirmar_igual "esperado" "$SAIDA"
    afirmar_contem "trecho" "$SAIDA"
}
```

### Particularidades dos testes deste curso
- Os testes rodam com o ambiente de [`ferramentas/lib/git-sandbox.sh`](ferramentas/lib/git-sandbox.sh) (Git isolado, identidade fixa, branch `main`) **e** com o **`glab` simulado** de [`ferramentas/lib/glab-simulado.sh`](ferramentas/lib/glab-simulado.sh) na frente do PATH. Nenhum teste pode depender de internet, de token ou de uma instância GitLab.
- Para conferir o que o script pediu ao GitLab: `afirmar_chamou_glab 'issue create*'`, `afirmar_nao_chamou_glab`, `contar_chamadas_glab`, `valor_opcao_glab 'mr create*' --title` e `entrada_glab` (corpo enviado por stdin). Os padrões são globs sobre a chamada em formato legível.
- Para dar ao script uma resposta específica: `simular_glab 'api *projects/*/protected_branches*' '[...]' [código-de-saída]`. Respostas padrão ficam em [`ferramentas/simulador/respostas/`](ferramentas/simulador/respostas/), escolhidas por [`mapa.tsv`](ferramentas/simulador/mapa.tsv).
- Para YAML/JSON (pipelines, templates, configurações): `afirmar_jq ARQUIVO 'filtro jq'` e `valor_jq`. Pipelines também passam por `afirmar_schema_gitlab_ci` (schema oficial, via `check-jsonschema`). O conversor do curso entende `!reference` e componentes com dois documentos (`spec` + corpo).
- Exemplos dos módulos copiam o cabeçalho gerado (laboratório em `mktemp -d`, Git isolado, `glab` simulado ou real com `GLAB_REAL=1`). Exemplos que alteram algo no GitLab de verdade só podem agir sobre `$LAB_PROJETO`.

### Scripts reais (`scripts/`)
Cada script em `scripts/<categoria>/<nome>.sh` tem um teste em `scripts/testes/<nome>.teste.sh`, rodado pela etapa 6 do `verificar-tudo.sh`. Scripts que apagam ou reescrevem algo devem **simular por padrão** ou exigir uma opção explícita.

## Fluxo do Pull Request

1. Faça um fork e crie uma branch: `git switch -c meu-ajuste`
2. Faça as mudanças seguindo o padrão acima
3. Rode `./ferramentas/verificar-tudo.sh` — tudo verde
4. Commit no padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/), em português
5. Abra o PR descrevendo **o quê** e **por quê**

## Estilo dos scripts (Bash) adotado

- `#!/usr/bin/env bash` (não `#!/bin/bash`)
- Em scripts de produção: `set -euo pipefail`
- **Sempre** aspas em variáveis: `"$var"`, `"${array[@]}"`
- `[[ ]]` em vez de `[ ]` (estamos em Bash, não POSIX sh)
- Nomes de função e variável em `snake_case`, português é bem-vindo
- `$(...)` em vez de crase `` `...` ``

## Código de conduta

Seja gentil. Estamos aqui para aprender e ensinar. Veja [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

<sub>© 2026 Prof. Daniel Santos</sub>
