# Exemplo: Vertical Slice de criação de produto

Exemplo didático para **.NET 10 / EF Core**, em um projeto ASP.NET Core. Pressupõe pacote EF Core + provider Npgsql já adicionados e connection string `AppDb` configurada por secret/env. Não executar migrations automaticamente. Adaptar ao projeto, não copiar sem testar. Inclui validação de entrada **e** invariantes de domínio: são responsabilidades distintas.

## Program.cs

```csharp
using App.Api.Modules.Catalog;
using App.Api.Persistence;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddProblemDetails();
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("AppDb")));

var app = builder.Build();
app.UseExceptionHandler();
app.MapGet("/health/live", () => TypedResults.Ok(new { status = "ok" }));
app.MapCatalog();
app.Run();

public partial class Program { } // Entry point acessível ao WebApplicationFactory.
```

Nota: este health check demonstra apenas disponibilidade do processo; criar readiness real quando houver dependências externas. Em produção, adicionar autenticação/autorização e proteção por rota conforme o domínio.

## Modules/Catalog/CatalogModule.cs

```csharp
using App.Api.Modules.Catalog.Features.CreateProduct;

namespace App.Api.Modules.Catalog;

public static class CatalogModule
{
    public static IEndpointRouteBuilder MapCatalog(this IEndpointRouteBuilder app)
    {
        var group = app.MapGroup("/api/products").WithTags("Catalog");
        CreateProduct.Map(group);
        return app;
    }
}
```

## Modules/Catalog/Domain/Product.cs

```csharp
namespace App.Api.Modules.Catalog.Domain;

public sealed class Product
{
    private Product() { } // EF Core

    private Product(Guid id, string name, decimal price)
    {
        Id = id;
        Name = name;
        Price = price;
    }

    public Guid Id { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public decimal Price { get; private set; }
    public const int MaxNameLength = 200;
    public const decimal MaxPrice = 9999999999999999.99m;

    // Política deste exemplo: moeda única definida pelo negócio, até 2 casas,
    // sem arredondamento implícito. Não generalizar para qualquer moeda.
    public static bool IsValidPrice(decimal price) =>
        price > 0 && price <= MaxPrice && decimal.Round(price, 2) == price;

    public static Product Create(string name, decimal price)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("Nome é obrigatório", nameof(name));
        name = name.Trim();
        if (name.Length > MaxNameLength)
            throw new ArgumentException("Nome excede o limite permitido", nameof(name));
        if (!IsValidPrice(price))
            throw new ArgumentOutOfRangeException(nameof(price));
        return new Product(Guid.NewGuid(), name, price);
    }
}
```

## Modules/Catalog/Features/CreateProduct/CreateProduct.cs

```csharp
using App.Api.Modules.Catalog.Domain;
using App.Api.Persistence;
using Microsoft.AspNetCore.Http.HttpResults;

namespace App.Api.Modules.Catalog.Features.CreateProduct;

public static class CreateProduct
{
    public sealed record Request(string? Name, decimal Price);
    public sealed record Response(Guid Id, string Name, decimal Price);

    public static void Map(RouteGroupBuilder routes) =>
        routes.MapPost("/", Handle).WithName("CreateProduct");

    public static async Task<Results<Created<Response>, ValidationProblem>> Handle(
        Request request,
        AppDbContext db,
        CancellationToken ct)
    {
        var errors = new Dictionary<string, string[]>();
        if (string.IsNullOrWhiteSpace(request.Name))
            errors[nameof(request.Name)] = ["Nome é obrigatório."];
        else if (request.Name.Trim().Length > Product.MaxNameLength)
            errors[nameof(request.Name)] = [$"Nome deve ter no máximo {Product.MaxNameLength} caracteres."];
        if (!Product.IsValidPrice(request.Price))
            errors[nameof(request.Price)] = ["Preço deve ser positivo, caber em numeric(18,2) e ter no máximo duas casas decimais."];
        if (errors.Count > 0)
            return TypedResults.ValidationProblem(errors);

        var product = Product.Create(request.Name!, request.Price);
        db.Products.Add(product);
        await db.SaveChangesAsync(ct);

        return TypedResults.Created(
            $"/api/products/{product.Id}",
            new Response(product.Id, product.Name, product.Price));
    }
}
```

A validação simples fica no endpoint neste exemplo por legibilidade. Em aplicações com muitos contratos, usar validação integrada ao .NET 10 (`Microsoft.Extensions.Validation` + `AddValidation()`) ou biblioteca já padronizada. Invariantes permanecem no domínio. Em endpoints protegidos, anexar `RequireAuthorization()` ao grupo ou rota e testar autorização por recurso.

## Persistence/AppDbContext.cs

```csharp
using App.Api.Modules.Catalog.Domain;
using Microsoft.EntityFrameworkCore;

namespace App.Api.Persistence;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options)
    : DbContext(options)
{
    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>(e =>
        {
            e.ToTable("products", "catalog");
            e.HasKey(p => p.Id);
            e.Property(p => p.Name).HasMaxLength(Product.MaxNameLength).IsRequired();
            e.Property(p => p.Price).HasPrecision(18, 2);
        });
    }
}
```

A migration deve criar o schema `catalog` ou o banco deve provisioná-lo antecipadamente; verificar o script gerado, não assumir que o schema existe. Usar teste de integração com PostgreSQL para validar mapeamento, transações e comportamento de criação.

`HasPrecision(18, 2)` não valida entrada. PostgreSQL arredonda casas excedentes; `0.001` poderia virar zero e `12.345` poderia divergir da resposta HTTP. Este exemplo rejeita esses valores, em vez de inventar uma regra de arredondamento. Em sistemas multimoeda, definir moeda e precisão no modelo de negócio. Para proteger gravações fora da aplicação, avaliar também constraints no banco; não presumir que o construtor de domínio valida materialização EF.

Para executar testes de domínio, HTTP e round-trip PostgreSQL deste código, ler `testing-example.md`. Para integrar Orders sem acessar `AppDbContext`, ler `example-module-contract.md`.

## Evolução se houver complexidade

- Cálculo de preço com múltiplas regras: extrair value object/serviço de domínio.
- Paginação: query separada com `AsNoTracking` e projeção.
- Pagamento externo: gateway testável por interface específica.
- Side effect com entrega confiável: outbox e consumidor idempotente.
- Isolamento mais forte: projeto e DbContext específicos de `Catalog`.
