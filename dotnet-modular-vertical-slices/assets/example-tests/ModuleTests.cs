using Catalog.Contracts;
using Orders;
using Xunit;

namespace App.Tests;

public sealed class ModuleTests
{
    [Fact]
    public async Task Orders_uses_public_catalog_contract()
    {
        var expected = new ProductSnapshot(Guid.NewGuid(), "Product", 12.34m);
        var fake = new FakeCatalog(expected);
        using var source = new CancellationTokenSource();
        var result = await new OrderProductReader(fake).FindProduct(expected.Id, source.Token);
        Assert.Equal(expected, result);
        Assert.Equal(expected.Id, fake.RequestedId);
        Assert.Equal(source.Token, fake.Token);
    }

    [Fact]
    public async Task Missing_product_remains_missing() =>
        Assert.Null(await new OrderProductReader(new FakeCatalog(null)).FindProduct(Guid.NewGuid(), default));

    [Fact]
    public void Orders_does_not_reference_catalog_implementation_or_EF()
    {
        var names = typeof(OrderProductReader).Assembly.GetReferencedAssemblies().Select(a => a.Name ?? "").ToArray();
        Assert.Contains("Catalog.Contracts", names);
        Assert.DoesNotContain(names, name => name == "App.Api" || name.StartsWith("Microsoft.EntityFrameworkCore", StringComparison.Ordinal));
    }

    private sealed class FakeCatalog(ProductSnapshot? product) : ICatalogQueries
    {
        public Guid RequestedId { get; private set; }
        public CancellationToken Token { get; private set; }

        public Task<ProductSnapshot?> FindProduct(Guid id, CancellationToken ct)
        {
            RequestedId = id;
            Token = ct;
            return Task.FromResult(product);
        }
    }
}
