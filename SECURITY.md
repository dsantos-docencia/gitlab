# Política de Segurança

Este é um repositório **didático**. Ainda assim, levamos segurança a sério — tanto do conteúdo quanto de quem o usa.

## Reportando um problema

Encontrou algo que possa prejudicar quem roda os exemplos (um script com efeito destrutivo não intencional, um vazamento de dados, uma dependência comprometida)?

- **Não abra uma issue pública** para vulnerabilidades sensíveis.
- Use o canal **[Security Advisories](https://github.com/dsantos-docencia/gitlab/security/advisories/new)** do GitHub (relato privado), ou entre em contato com o mantenedor.
- Para erros comuns (um exemplo que falha, um link quebrado), uma [issue normal](https://github.com/dsantos-docencia/gitlab/issues/new/choose) está ótima.

## O que esperamos de você

Ao usar este material:

- **Rode em ambiente seguro.** Os exemplos foram escritos para rodar em diretórios temporários, mas o laboratório em container (`laboratorio/`) é a forma mais segura de praticar.
- **Nunca** commite segredos, senhas, chaves ou dados pessoais em contribuições. Nossa esteira e a revisão tentam barrar isso, mas a primeira linha de defesa é você.
- Os scripts reais em [`scripts/`](scripts/) **alteram sistemas** — leia os avisos antes de executar.

## Compromisso do mantenedor

- Avaliar relatos de segurança com prioridade.
- Manter o `scripts/comunidade/` curado: nada entra sem revisão.
- Varredura de segredos e alertas de dependência habilitados no repositório.

Obrigado por ajudar a manter este espaço seguro para quem está aprendendo. 🛡️
