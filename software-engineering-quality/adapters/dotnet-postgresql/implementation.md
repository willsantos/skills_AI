# Adapter ASP.NET Core + EF Core + PostgreSQL: aplicação e organização

**Quando usar:** repositório ASP.NET Core com EF Core e PostgreSQL, em especial monólito modular + vertical slices. Este adapter oferece implementação concreta; regras universais continuam em `references/`.

## Organização mínima, não mandatória

```text
src/
  Modules/
    Orders/
      CreateOrder/
        Endpoint.cs
        Request.cs
        Handler.cs
      GetOrder/
      Domain/
      Data/
tests/
  App.IntegrationTests/
```

Preserve o layout existente. Para uma feature simples, `Endpoint` e `Handler` podem ser um arquivo pequeno se o projeto já adotar isso; não crie camadas que apenas passam dados adiante.

### Responsabilidades

- `Endpoint`: definir rota, auth requirement, parsing/validation de contrato, status HTTP e delegação.
- `Handler`: carregar dados com escopo do usuário, validar invariantes, coordenar uma transação e efeitos locais, produzir resultado.
- `Domain`: centralizar transições e cálculos reutilizados ou complexos; não criar entidades anêmicas extras por princípio.
- `Data`: mapeamentos, migrações, índices, constraints, queries de persistência. `DbContext` direto no handler é aceitável na arquitetura existente.
- Integrações: `HttpClientFactory` com cancelamento/timeout; sem segredos no frontend; outbox se precisar coordenar efeitos externos.

## Autorização e payloads

```csharp
// Identidade vem da autenticação validada; nunca do body como autoridade.
var userId = userContext.RequiredUserId;

var order = await db.Orders
    .Where(o => o.Id == orderId && o.UserId == userId)
    .SingleOrDefaultAsync(ct);
```

- Criação de pedido recebe `ProductId` e `Quantity`, **não** `UnitPrice` ou `Total` como valores autoritativos.
- Claims, roles e tenant vêm do principal autenticado/contexto servidor; consultar política granular de autorização.
- Evitar dados privados em logs e exceções HTTP. Validar tamanho de entrada e usar queries parametrizadas.
- Para entidades multi-tenant, aplicar filtros por tenant em todas as operações; se usar RLS, configurar role sem bypass e variável `SET LOCAL` de forma confiável **na mesma transação**, com testes de isolamento.

## Mapeamentos e constraints

```csharp
builder.Entity<Product>(e =>
{
    e.ToTable("products", t => t.HasCheckConstraint(
        "ck_products_stock_nonnegative", "stock >= 0"));
    e.HasKey(x => x.Id);
});

builder.Entity<ProcessedEvent>(e =>
{
    e.ToTable("processed_events");
    e.HasKey(x => new { x.Provider, x.EventId });
});
```

Confirmar convenção de nomes/quotes/identificadores no projeto e não duplicar constraint existente. Migrações versionadas devem produzir o SQL esperado; índices e constraints precisam existir na base real de produção.

## Erros, status e retorno

- `400/422`: input inválido, conforme contrato do projeto.
- `401`: sem identidade autenticada; `403`: proibido; `404` pode ocultar existência do recurso, conforme política.
- `409`: conflito de estado ou idempotency key incompatível; quantidade insuficiente pode usar `409`/`422` conforme convenção existente.
- `500/503`: falha real do servidor ou dependência indisponível; não retornar sucesso para processamento local não concluído.
- `ProblemDetails` ou erro padronizado existente: não vazar detalhes de conexão, SQL ou segredos.

## Preferências pragmáticas

- `DbContext` diretamente no handler é válido; abstrair apenas quando necessário.
- Para cálculos puros, usar classes/funções de domínio sem dependência de EF.
- Usar `CancellationToken` do request nas operações relevantes, respeitando semântica de commit/recovery.
- Instrumentar via logging estruturado/Activity/OpenTelemetry existentes.
- Evitar introduzir MediatR, AutoMapper, repositories genéricos ou CQRS como requisito implícito.

Leitura complementar obrigatória para mutações concorrentes ou webhooks: [concurrency-and-idempotency.md](concurrency-and-idempotency.md). Para testes: [testing.md](testing.md).

Fontes: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis/ e https://learn.microsoft.com/en-us/ef/core/
