# Adapter Node.js + TypeScript + PostgreSQL (Fastify / Nest / Express)

## Organização

- Route/controller: contrato HTTP, schema de entrada, autenticação e status.
- Use case/service: regra de negócio, autorização, limites de transação e resultados.
- Repository/query module: SQL parametrizado e persistência quando houver utilidade real; sem repository genérico obrigatório.
- Framework escolhido não substitui garantias de banco e segurança.

## Transação com node-postgres (`pg`)

A transação precisa reutilizar **o mesmo client** adquirido do pool. Nunca usar `pool.query()` alternadamente dentro de uma transação, pois cada chamada pode receber conexão distinta.

```ts
import { Pool } from 'pg';

const pool = new Pool();

async function reserveAndCreateOrder(
  productId: string,
  quantity: number,
  userId: string
) {
  if (!Number.isSafeInteger(quantity) || quantity <= 0)
    throw new Error('invalid quantity');

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const reserve = await client.query(
      `UPDATE products
       SET stock = stock - $2
       WHERE id = $1 AND stock >= $2
       RETURNING id`,
      [productId, quantity]
    );
    if (reserve.rowCount !== 1) {
      await client.query('ROLLBACK');
      return { ok: false, reason: 'insufficient-stock-or-missing' };
    }

    const order = await client.query(
      `INSERT INTO orders (product_id, quantity, user_id)
       VALUES ($1, $2, $3) RETURNING id`,
      [productId, quantity, userId]
    );
    await client.query('COMMIT');
    return { ok: true, orderId: order.rows[0].id };
  } catch (error) {
    try { await client.query('ROLLBACK'); } catch { /* preserve original error */ }
    throw error;
  } finally {
    client.release();
  }
}
```

O trecho demonstra atomicidade. Em produção, price snapshot, autorização, idempotência HTTP e estados de pedido precisam ser incorporados conforme contrato de negócio. `userId` deve vir de identidade autenticada, não do JSON recebido. Evitar instanciar `new Pool()` por request: pool é compartilhado/ciclo de vida da aplicação.

## Webhook e retries

- Verificar assinatura sobre corpo bruto antes de parsear/normalizar de forma que invalide assinatura.
- `INSERT ... ON CONFLICT DO NOTHING` e efeito em **uma transação no mesmo `client`**; chave composta por provedor e ID.
- Consumidor de fila e outbox devem deduplicar efeitos, inclusive múltiplos event IDs do mesmo recurso.
- `AbortSignal`/timeout na camada de integração; retries somente com semântica segura.

## Validação, autorização e testes

- Adotar validador de schema já presente (`JSON Schema`, Zod etc.), rejeitar campos inesperados quando contrato exigir.
- Escopo de tenant e usuário aplicado nas consultas e mutações; nunca confiar em `tenantId` do frontend.
- Fastify: `inject()` para testes HTTP; Nest: testing module e supertest; outros frameworks usam cliente de teste equivalente.
- Testcontainers + PostgreSQL real para constraints, transações, interleaving e acesso multi-tenant; Playwright pontualmente no frontend.

Fontes: https://node-postgres.com/features/transactions ; https://node-postgres.com/features/queries
