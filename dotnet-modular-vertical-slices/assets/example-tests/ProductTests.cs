using System.Globalization;
using App.Api.Modules.Catalog.Domain;
using Xunit;

namespace App.Tests;

public sealed class ProductTests
{
    [Theory]
    [InlineData("0")]
    [InlineData("-1")]
    [InlineData("0.001")]
    [InlineData("12.345")]
    [InlineData("10000000000000000")]
    public void Rejects_prices_outside_policy(string input)
    {
        var price = decimal.Parse(input, CultureInfo.InvariantCulture);
        Assert.Throws<ArgumentOutOfRangeException>(() => Product.Create("Product", price));
    }

    [Theory]
    [InlineData("0.01")]
    [InlineData("12.34")]
    [InlineData("9999999999999999.99")]
    public void Preserves_supported_prices(string input)
    {
        var price = decimal.Parse(input, CultureInfo.InvariantCulture);
        Assert.Equal(price, Product.Create(" Product ", price).Price);
    }

    [Theory]
    [InlineData("")]
    [InlineData(" ")]
    public void Rejects_blank_names(string name) =>
        Assert.Throws<ArgumentException>(() => Product.Create(name, 1m));

    [Fact]
    public void Enforces_normalized_name_length()
    {
        Assert.Equal(new string('a', Product.MaxNameLength),
            Product.Create(" " + new string('a', Product.MaxNameLength) + " ", 1m).Name);
        Assert.Throws<ArgumentException>(() => Product.Create(new string('a', Product.MaxNameLength + 1), 1m));
    }
}
