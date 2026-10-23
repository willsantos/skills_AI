using System.Net;
using System.Net.Http.Json;
using System.Globalization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace App.Tests;

public sealed class ApiFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        // Invalid requests must stop before touching the database.
        builder.UseSetting("ConnectionStrings:AppDb",
            "Host=127.0.0.1;Port=1;Database=unused_skill_tests;Username=unused;Password=unused;Timeout=1");
        builder.UseEnvironment("Testing");
        builder.UseContentRoot(Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "../../../../App.Api")));
    }
}

public sealed class HttpTests : IClassFixture<ApiFactory>
{
    private readonly HttpClient client;

    public HttpTests(ApiFactory factory) => client = factory.CreateClient();

    [Theory]
    [InlineData("", "1")]
    [InlineData("Product", "0")]
    [InlineData("Product", "0.001")]
    [InlineData("Product", "12.345")]
    [InlineData("Product", "10000000000000000")]
    public async Task Invalid_requests_return_validation_problem(string name, string input)
    {
        var price = decimal.Parse(input, CultureInfo.InvariantCulture);
        var response = await client.PostAsJsonAsync("/api/products/", new { Name = name, Price = price });
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task Oversized_name_is_rejected()
    {
        var response = await client.PostAsJsonAsync("/api/products/", new { Name = new string('a', 201), Price = 1m });
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
