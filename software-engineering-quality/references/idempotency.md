# Idempotência, deduplicação e consistência de efeitos

## Modelo mental

Repetir a mesma intenção não deve criar efeitos de negócio extras. Não é o mesmo que executar código uma vez: delivery de webhooks e filas costuma ser **at-least-once**. Reconheça duplicidade mesmo com várias instâncias e falhas no meio da execução.

## Diferencie três IDs

- **Event ID:** identifica uma entrega/evento do provedor. Use `UNIQUE(provider, event_id)` para bloquear reprocessamento idêntico.
- **Business ID:** identifica a intenção/objeto (pedido, pagamento, compra, ledger entry). Eventos diferentes podem representar a mesma ação e exigem unicidade/transição no domínio.
- **Idempotency-Key HTTP:** identifica uma intenção do cliente; associe a ator/escopo, rota e hash canônico dos parâmetros; defina retenção e resultado para retries.

## Webhook: transação correta

1. Verificar assinatura sobre payload bruto e frescor/tolerância de timestamp, conforme provedor.
2. Normalizar e identificar evento e recurso sem confiar cegamente no payload.
3. Iniciar transação no banco; registrar o evento com índice único (`INSERT ... ON CONFLICT DO NOTHING`). Se já processado, encerrar sem duplicar o efeito.
4. Verificar pedido, valor, moeda, correspondência com provedor e transição atual; efetuar alteração de negócio **na mesma transação**.
5. Registrar outbox na mesma transação caso existam efeitos assíncronos externos.
6. Commit. Apenas depois responder sucesso ao provedor. Em falha, rollback e resposta apropriada para retry.

**Detalhe:** receber eventos fora de ordem é possível; um `payment.failed` atrasado não pode reverter `paid` sem regra explícita. Um evento pode ser duplicado semanticamente com outro event ID.

```sql
BEGIN;
INSERT INTO processed_events(provider, event_id)
VALUES (:provider, :event_id)
ON CONFLICT DO NOTHING
RETURNING event_id;
-- Se não inseriu: já tratado; não repetir efeito.

UPDATE orders SET status = 'paid'
WHERE id = :order_id AND status = 'pending'
RETURNING id;
-- Validar payload e estado de negócio antes da transição.
-- Se necessário, INSERT INTO outbox (...)
COMMIT;
```

Este SQL ilustra o padrão e **não é um handler pronto**: se a atualização não afetar linhas, distinguir duplicidade, estado incompatível, erro ou falta de dados antes de confirmar o processamento.

## Chave HTTP para criação

Estados úteis: `processing` (com lease/timeout definido), `completed`, `failed_retryable` ou política equivalente. Persistir ator/escopo, hash do pedido e resposta reproduzível; rejeitar chave reutilizada com payload diferente. Resolver simultaneidade com `UNIQUE` e transação/coordenação. Não retornar sucesso fictício enquanto primeira tentativa ainda processa: responder conflito/retry ou aguardar de maneira controlada conforme contrato.

## Side effects fora do banco

- Banco não faz rollback de chamadas HTTP, e-mails, filas nem LLM.
- **Transactional Outbox:** inserir evento e mudança de negócio na mesma transação. Publicador assíncrono entrega ao destino; consumidor também deduplica. Pode haver publicação repetida após crash do publicador.
- Sistemas externos devem aceitar chave idempotente quando possível; de outro modo, reconciliar com estado remoto.
- Retry apenas quando operação pode ser refeita de modo seguro; cuidado com requisições HTTP `POST` não idempotentes.

## Testes mínimos

- Mesmo ID repetido sequencialmente e simultaneamente resulta em um único efeito.
- IDs distintos para mesmo pagamento respeitam transições/uniqueness de domínio.
- Crash/rollback antes do commit permite retry futuro.
- Payload diferente com a mesma chave é rejeitado.
- Worker com entrega duplicada não duplica crédito ou mensagem de domínio.

Evitar: `SELECT` para saber se existe evento antes de `INSERT` sem unique; inserir marcador em transação separada do efeito; limpar chaves sem política; tratar `exactly once` como capacidade garantida de uma fila.

Referências: https://docs.stripe.com/webhooks e https://docs.stripe.com/api/idempotent_requests
