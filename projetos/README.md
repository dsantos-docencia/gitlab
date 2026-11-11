# 🚀 Projetos práticos

Três ferramentas de verdade, que juntam vários módulos e que você pode usar no dia seguinte. Cada uma tem testes (rodados pela etapa 5 de `./ferramentas/verificar-tudo.sh`) e uma lista de desafios para ir além.

| # | Projeto | O que faz | Módulos |
|---|---|---|---|
| 01 | [Kit de projeto](01-kit-de-projeto/) | deixa um projeto “pronto para time” em um comando: templates de issue e MR, CODEOWNERS com seções, pipeline com scanners e, pela API, regras de merge e proteção da branch padrão e das tags — idempotente | 03 · 04 · 06 · 07 · 10 |
| 02 | [Auditor de projeto](02-auditor-de-projeto/) | nota de 0 a 10 para a higiene de um projeto (proteções, regras de merge, Maintainers demais, variáveis sem máscara, webhooks desativados, token do job), só lendo a API; texto ou JSON | 02 · 06 · 10 · 11 |
| 03 | [Componente de pipeline](03-componente-de-pipeline/) | modelo de repositório de **componente de CI/CD** pronto para o Catalog, com um verificador que pega entradas não declaradas, tipos errados e imagens sem versão antes do push | 07 · 08 · 09 |

Sugestão de ordem: faça o **01** depois do Módulo 07, o **03** depois do Módulo 09 e o **02** no final do curso.

<sub>© 2026 Prof. Daniel Santos · Curso de GitLab · código PolyForm-NC, textos CC BY-NC-SA 4.0</sub>
