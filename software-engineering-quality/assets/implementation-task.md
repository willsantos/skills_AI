# Template de tarefa para agente: implementação

## Objetivo

[Feature, cenário de uso e resultado esperado]

## Contexto

[Repositório, stack, módulo, padrões existentes, comandos de teste]

## Contrato

- Entradas permitidas: [campos do cliente e validação]
- Identidade/autorização: [fonte confiável e quem pode agir]
- Invariantes: [condições sempre verdadeiras]
- Repetição e concorrência: [o que acontece em retry/double click/duas requisições simultâneas; ou N/A]
- Efeitos externos: [timeout, retry, outbox/reconciliação; ou N/A]

## Restrições de implementação

Respeitar a arquitetura atual, evitar novas camadas e dependências sem necessidade, proteger invariantes no banco quando aplicável, não publicar secret em frontend ou logs.

## Aceite verificável

- [ ] Caminho feliz.
- [ ] Entrada inválida e ausência de autorização.
- [ ] Concorrência/duplicação se aplicável.
- [ ] Falha e rollback/recovery se aplicável.
- [ ] Testes rodados (com comandos/resultados). Se impossível, declarar a limitação.

## Entrega

Resumir mudança, garantias, evidências de testes e riscos residuais.
