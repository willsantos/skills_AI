# Consistência, concorrência e efeitos externos

Ler antes de alterar escritas concorrentes, unicidade, integrações com efeitos externos ou publicação de eventos. Aplicar apenas mecanismos exigidos pelos requisitos; não adicionar outbox, locks ou transações explícitas a todo CRUD.

## Escolher fronteira de atomicidade

| Operação | Decisão |
|---|---|
| Uma chamada `SaveChangesAsync` | Provider relacional normalmente garante transação para as alterações dessa chamada; não envolver em outra transação sem necessidade. |
| Vários saves que devem confirmar juntos | Usar transação explícita, escopo curto e rollback em falha; considerar strategy de execução/retry do provider. |
| Vários DbContexts | Não presumir atomicidade compartilhada. Se suportado e necessário, compartilhar conexão/transação explicitamente; caso contrário, desenhar compensação/consistência eventual. |
| Gravação + mensagem com entrega obrigatória | Persistir estado e outbox na mesma transação; publicar depois, com reentrega e deduplicação. |
| Banco + cobrança HTTP externa | Transação de banco não desfaz cobrança. Usar idempotência no gateway, estado persistido e reconciliação/compensação. |

Evitar chamadas remotas dentro de transações longas. Documentar o que ocorre se processo cair antes e depois de cada efeito. Um evento em memória após commit não oferece entrega durável.

## Concorrência e unicidade

1. Identificar operação read-modify-write, por exemplo estoque, saldo ou transição de status. Definir se política será token otimista, atualização SQL condicional ou lock justificado pelo provider.
2. Com token otimista configurado, tratar `DbUpdateConcurrencyException`: recarregar e reavaliar regras ou devolver conflito conforme contrato. Não repetir cegamente uma operação com efeitos externos.
3. Testar com duas instâncias de DbContext lendo mesma versão: primeiro save vence; segundo deve falhar ou seguir política explícita, nunca sobrescrever silenciosamente quando perda de atualização for proibida.
4. Para unicidade, criar índice/constraint no banco, incluindo tenant quando necessário. Consulta prévia serve para UX, não protege corrida entre requisições.
5. Tratar somente violações conhecidas pelo código/constraint do provider, mapeando para erro de negócio/409 quando adequado. Não converter todo `DbUpdateException` em conflito: falha de conexão e schema quebrado não são duplicidade.

`DbUpdateConcurrencyException` não é tratamento geral para insert duplicado; violação de unicidade usa exceção específica do provider. Tokens e mecanismos como SQL Server rowversion ou PostgreSQL xmin não são intercambiáveis; consultar documentação da versão real.

## Idempotência e retries

- Definir chave estável e escopo: tenant + operação + chave. Persistir hash do pedido e resultado/status, com unicidade atômica. Não armazenar apenas em memória.
- Mesma chave e mesmo pedido: reutilizar resultado conforme contrato. Mesma chave e conteúdo diferente: rejeitar. Definir comportamento para execução em andamento, timeout, TTL e recuperação após crash.
- Associar deduplicação e efeito local à mesma transação quando possível. Para gateway, encaminhar chave estável suportada pelo provedor e reconciliar resultado desconhecido antes de nova tentativa.
- Outbox entrega normalmente é at-least-once: consumidor precisa deduplicar evento na mesma transação do efeito local. Não prometer exactly-once ponta a ponta.
- Retry limitado, cancelável, com backoff/jitter, apenas para falhas transitórias e operações seguras. Não repetir pagamento sem suporte de idempotência.

## Evidência mínima

- Teste de duas escritas concorrentes e política de conflito.
- Teste de duas criações com mesma chave única, garantindo uma única gravação.
- Teste de repetição da chave idempotente, payload divergente e execução concorrente.
- Teste de queda entre commit/publicação e reentrega sem efeito duplicado quando houver outbox.

## Fontes

- [Transações EF Core](https://learn.microsoft.com/en-us/ef/core/saving/transactions).
- [Concorrência EF Core](https://learn.microsoft.com/en-us/ef/core/saving/concurrency).
- [Transactional Outbox](https://microservices.io/patterns/data/transactional-outbox.html).
