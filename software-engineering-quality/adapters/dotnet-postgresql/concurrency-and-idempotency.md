# Adapter .NET + PostgreSQL: concorrência, transações e idempotência

## Atualização de estoque atômica

O EF Core dispõe de `ExecuteUpdateAsync`, adequado quando a regra cabe em uma condição SQL.

```csharp
// Retorna número de linhas afetadas. Este comando é atômico por si só.
var affected = await db.Products
    .Where(p => p.Id == productId && p.Stock >= quantity)
    .ExecuteUpdateAsync(setters => setters
        .SetProperty(p => p.Stock, p => p.Stock - quantity), ct);

if (affected != 1)
    return ReserveResult.OutOfStockOrNotFound();
```

Requisitos: `quantity > 0` deve ser validado previamente; índice em `Id`; check DB `stock >= 0`; verificar `affected`; preservar semântica existente para ausência/falta de estoque. Este comando **não usa change tracker** e **não coordena automaticamente outra gravação**.

## Pedido + estoque: transação explícita

```csharp
await using var tx = await db.Database.BeginTransactionAsync(ct);

var affected = await db.Products
    .Where(p => p.Id == productId && p.Stock >= quantity)
    .ExecuteUpdateAsync(setters => setters
        .SetProperty(p => p.Stock, p => p.Stock - quantity), ct);

if (affected != 1)
{
    await tx.RollbackAsync(ct);
    return CreateOrderResult.OutOfStock();
}

db.Orders.Add(new Order
{
    ProductId = productId,
    Quantity = quantity,
    UserId = authenticatedUserId,
    // Price deve ser consultado/validado pelo servidor.
});

await db.SaveChangesAsync(ct);
await tx.CommitAsync(ct);
return CreateOrderResult.Created();
```

**Exemplo didático, não pronto para checkout de produção:** consultar preço e verificar política de desconto antes de confirmar, armazenar preço congelado e testar falhas intermediárias. Se `SaveChangesAsync` falhar, dispose/rollback remove reserva de estoque. A mesma unidade de negócio deve usar o mesmo contexto/transação.

**Armadilha EF:** `ExecuteUpdateAsync` persiste imediatamente e não sincroniza entidades rastreadas. Não modificar a mesma instância `Product` no change tracker, depois chamar `SaveChanges` sem recarregar/gerenciar tracking, pois pode sobrescrever valor atualizado. Em múltiplas chamadas de `ExecuteUpdateAsync`, usar transação explícita.

## Controle otimista com tokens

Para operações de edição, usar concurrency token configurado (coluna de versão ou mecanismo do provider). `SaveChangesAsync` pode lançar `DbUpdateConcurrencyException`; decidir se reconsulta, rejeita conflito ou repete com limite.

`ExecuteUpdateAsync` **não** aplica automaticamente tokens. Inclua a versão no filtro e verifique linhas afetadas:

```csharp
var changed = await db.Orders
    .Where(o => o.Id == orderId && o.Version == expectedVersion)
    .ExecuteUpdateAsync(s => s
        .SetProperty(o => o.Status, OrderStatus.Cancelled)
        .SetProperty(o => o.Version, o => o.Version + 1), ct);

if (changed != 1) return CancelResult.Conflict();
```

Exige que todas as rotas que alteram o recurso respeitem a convenção de versão e as demais regras de transição; acrescentar status esperado ao `Where` quando necessário.

## Webhook com marker e efeito na mesma transação

Validar assinatura do provedor sobre os bytes originais do payload **antes** de executar o exemplo. Usar índice único em `(provider, event_id)` e validar pedido, valor, moeda e estado. SQL interpolado do EF é parametrizado; `ExecuteSqlRaw` montado por concatenação não é seguro.

```csharp
await using var tx = await db.Database.BeginTransactionAsync(ct);

var inserted = await db.Database.ExecuteSqlInterpolatedAsync($"""
    INSERT INTO processed_events (provider, event_id)
    VALUES ({provider}, {eventId})
    ON CONFLICT (provider, event_id) DO NOTHING
    """, ct);

if (inserted == 0)
{
    await tx.RollbackAsync(ct);
    return WebhookResult.AlreadyProcessed();
}

// Antes do UPDATE: correlacione evento com pedido, valor, moeda,
// provedor e transição legal. Não confiar no identificador isoladamente.
var changed = await db.Orders
    .Where(o => o.Id == orderId && o.Status == OrderStatus.Pending)
    .ExecuteUpdateAsync(s => s
        .SetProperty(o => o.Status, OrderStatus.Paid), ct);

// Decidir explicitamente o que significa changed == 0:
// evento semanticamente redundante, fora de ordem ou inválido.
// Se houver evento para publicar, gravar Outbox na mesma transação.
await tx.CommitAsync(ct);
return WebhookResult.Accepted(changed == 1);
```

No exemplo, `changed == 0` **não** pode ser aceito automaticamente sem confirmar que a situação é esperada e o evento é válido; adaptar essa decisão à máquina de estados do domínio antes de usar o trecho. Nunca disparar e-mail/gateway dentro da transação supondo rollback externo. Para efeito fora do banco, usar outbox/reconciliação/idempotência no destino.

## `FOR UPDATE` e SQL raw

Se precisar de leitura bloqueante, obter mesma conexão/transação do EF e executar `SELECT ... FOR UPDATE` via suporte SQL do provider, com tipos/resultados adequados. Excluir trecho de código genérico sem contexto do modelo. Não usar `FOR UPDATE` fora de transação explícita se o lock precisa sobreviver até outras operações.

## Testes esperados

1. Duas requisições concorrentes com estoque 1 => 1 sucesso, 1 falha, estoque 0.
2. Exceção após reserva e antes de gravar pedido => rollback de estoque.
3. Webhook mesmo event ID simultâneo => apenas um processamento.
4. Dois event IDs relacionados ao mesmo pagamento => uma transição/efeito de negócio.
5. Dois usuários/tenants alternados no pool => nenhum vazamento de dados.

Fontes: https://learn.microsoft.com/en-us/ef/core/saving/execute-insert-update-delete ; https://learn.microsoft.com/en-us/ef/core/saving/concurrency ; https://www.postgresql.org/docs/current/transaction-iso.html
