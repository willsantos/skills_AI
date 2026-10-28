# Resiliência, retries e sistemas externos

## Defina a fronteira de falha

Quais chamadas saem do processo ou banco? Um timeout não significa que a operação remota falhou: ela pode ter sido concluída, mas a resposta se perdeu. A estratégia precisa preservar semântica de negócio diante de sucesso incerto.

## Estratégia proporcional

- **Timeouts e cancelamento:** limite cada chamada, herde deadline da requisição quando apropriado, não use timeout infinito.
- **Retries:** somente para falhas transitórias e operação segura para repetição (ou protegida por chave de idempotência). Use limite de tentativas, exponential backoff com jitter e respeite `Retry-After` quando adequado.
- **Circuit breaker:** somente se medições indicarem cascatas ou overload recorrente; fallback explícito, não ocultar falhas críticas.
- **Fila/job:** quando desacoplamento e processamento assíncrono agregarem valor. Configurar ack, retry, limite de tentativas, DLQ e observabilidade.
- **Outbox:** quando alteração do banco e publicação precisarem ser coordenadas sem transação distribuída. Consumidores devem aceitar eventos duplicados.
- **Reconciliation:** processo de confronto entre estado local e remoto em pagamentos e transações críticas; webhook não deve ser única fonte para sempre.
- **Bulkhead/backpressure:** limites de concorrência e filas internas limitadas quando necessária proteção de recursos.

## Anti-padrões de retry

- Fazer retry de cobrança POST sem chave idempotente.
- Retry sobre erro de validação ou falta de permissão (4xx permanentes).
- Executar chamada lenta ao provedor dentro de transação que bloqueia linha de estoque.
- Engolir exceção e retornar 200/OK quando trabalho não foi persistido.
- Publicar evento e atualizar banco em operações independentes, afirmando que é atômico.
- Afirmar entrega exactly-once em fluxo distribuído que suporta apenas at-least-once.

## Perguntas de auditoria

Quem toma a decisão de retry? Como o sistema distingue falha permanente/transitória? Qual é o tempo máximo de espera? O que ocorre quando o consumidor reinicia após executar o efeito mas antes de confirmar mensagem? Como detectar mensagens estacionadas em DLQ? É possível repetir sem duplicar créditos?

## Testes e operação

Injetar timeout antes/depois da confirmação remota, 429, 503, falha entre commit e publicação, eventos fora de ordem, falha prolongada e replay da DLQ. Verificar invariantes persistidas e eventual recuperação. Expor métricas de tentativas, outbox pendente, idade da fila e falhas permanentes.
