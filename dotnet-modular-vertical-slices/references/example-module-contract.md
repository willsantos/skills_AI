# Exemplo: Orders consulta Catalog por contrato

Ler ao integrar módulos ou tornar fronteiras verificáveis. Este exemplo estende `example-create-product.md`; `scripts/verify-example.py` compila os blocos abaixo em assemblies separados e executa testes em `assets/example-tests/`.

## Dependências

```text
App.Api (host + implementação Catalog) → Catalog.Contracts
App.Api → Orders → Catalog.Contracts
Catalog.Contracts → nenhuma dependência de persistência/HTTP
```

Orders não referencia App.Api, EF Core nem entidades Catalog. Catalog.Contracts contém apenas o contrato público e DTO imutável; não expor IQueryable, DbContext ou entidade rastreada. Em sistema maior, separar também implementação Catalog do host. Isso é uma escolha didática de assemblies, não uma estrutura obrigatória para todo projeto.

## Catalog.Contracts/ProductSnapshot.cs

```csharp
namespace Catalog.Contracts;

public sealed record ProductSnapshot(Guid Id, string Name, decimal Price);

public interface ICatalogQueries
{
    Task<ProductSnapshot?> FindProduct(Guid id, CancellationToken ct);
}
```

## Orders/OrderProductReader.cs

```csharp
using Catalog.Contracts;

namespace Orders;

public sealed class OrderProductReader(ICatalogQueries catalog)
{
    public Task<ProductSnapshot?> FindProduct(Guid productId, CancellationToken ct) =>
        catalog.FindProduct(productId, ct);
}
```

## App.Api/Modules/Catalog/CatalogQueries.cs

```csharp
using App.Api.Persistence;
using Catalog.Contracts;
using Microsoft.EntityFrameworkCore;

namespace App.Api.Modules.Catalog;

internal sealed class CatalogQueries(AppDbContext db) : ICatalogQueries
{
    public Task<ProductSnapshot?> FindProduct(Guid id, CancellationToken ct) =>
        db.Products.AsNoTracking()
            .Where(p => p.Id == id)
            .Select(p => new ProductSnapshot(p.Id, p.Name, p.Price))
            .SingleOrDefaultAsync(ct);
}
```

O sandbox registra `AddScoped<ICatalogQueries, CatalogQueries>()` e `AddScoped<OrderProductReader>()` no composition root. Não fazer service location nem registrar entidades como serviços.

## Garantias e limites

- Teste de contrato: fake de ICatalogQueries comprova que Orders encaminha ID e cancelamento sem depender do banco.
- Teste arquitetural: referências do assembly Orders não podem incluir App.Api nem namespaces de assemblies EF Core. A separação dos projetos impede acesso ao contexto sem introduzir nova referência; o teste detecta dependência efetivamente usada. Também revisar ProjectReference e dependências transitivas no CI.
- Esse teste não é um sandbox de segurança: reflection, SQL manual e dependências não utilizadas podem escapar. Para proibir acessos adicionais, adicionar analyzers/testes adequados ao repositório.
- Produto ausente retorna null; consumidor decide comportamento de negócio. Não inventar preço zero como fallback.
- Catálogo deste exemplo é público e sem tenant. Em aplicação multi-tenant, obter tenant autorizado no servidor e incluí-lo no contrato/filtro; nunca aceitar tenant arbitrário do cliente sem autorização.
- Ler preço atual não resolve consistência de checkout: quando pedido precisa congelar preço, persistir snapshot e definir política de validade/revalidação. Uma chamada de contrato não cria transação distribuída.
