using System.Globalization;
using System.Net;
using System.Net.Http.Json;
using App.Api.Modules.Catalog.Domain;
using App.Api.Modules.Catalog.Features.CreateProduct;
using App.Api.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using Orders;
using Xunit;

namespace App.Tests;

[Trait("Category", "Postgres")]
public sealed class PostgresTests
{
    private static string ConnectionString()
    {
        var raw = Environment.GetEnvironmentVariable("SAMPLE_POSTGRES")
            ?? throw new InvalidOperationException("SAMPLE_POSTGRES must point to a disposable local database ending in _skill_tests.");
        var value = new NpgsqlConnectionStringBuilder(raw);
        if (value.Host is not ("localhost" or "127.0.0.1") ||
            value.Database?.EndsWith("_skill_tests", StringComparison.Ordinal) != true)
            throw new InvalidOperationException("Only explicit local disposable *_skill_tests databases are allowed.");
        return raw;
    }

    private static AppDbContext Context(string connectionString) =>
        new(new DbContextOptionsBuilder<AppDbContext>().UseNpgsql(connectionString).Options);

    [Theory]
    [InlineData("0.01")]
    [InlineData("12.34")]
    [InlineData("9999999999999999.99")]
    public async Task Http_create_matches_value_read_with_fresh_context(string input)
    {
        var connectionString = ConnectionString();
        await using (var setup = Context(connectionString))
            await setup.Database.EnsureCreatedAsync();
        await using var factory = new ApiFactory().WithWebHostBuilder(builder =>
            builder.UseSetting("ConnectionStrings:AppDb", connectionString));
        using var client = factory.CreateClient();
        var price = decimal.Parse(input, CultureInfo.InvariantCulture);
        var response = await client.PostAsJsonAsync("/api/products/", new { Name = "Round-trip", Price = price });
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<CreateProduct.Response>();
        Assert.NotNull(body);
        Assert.Equal(price, body.Price);
        await using var db = Context(connectionString);
        var persisted = await db.Products.AsNoTracking().SingleAsync(p => p.Id == body.Id);
        Assert.Equal(body.Price, persisted.Price);
        Assert.Equal(body.Name, persisted.Name);
        Assert.Equal($"/api/products/{body.Id}", response.Headers.Location?.ToString());

        await using var scope = factory.Services.CreateAsyncScope();
        var snapshot = await scope.ServiceProvider.GetRequiredService<OrderProductReader>()
            .FindProduct(body.Id, default);
        Assert.NotNull(snapshot);
        Assert.Equal(body.Name, snapshot.Name);
        Assert.Equal(body.Price, snapshot.Price);
    }
}
