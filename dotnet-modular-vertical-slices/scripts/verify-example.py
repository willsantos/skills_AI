#!/usr/bin/env python3
"""Materialize documented C# examples into a new sandbox and run their tests."""

import argparse
from pathlib import Path
import re
import shutil
import subprocess
import xml.etree.ElementTree as ET


def run(*args: str, cwd: Path) -> None:
    subprocess.run(args, cwd=cwd, check=True)


def test(destination: Path, category: str, label: str) -> None:
    results = destination / "test-results" / label
    run("dotnet", "test", "App.Tests/App.Tests.csproj", "--no-build", "--filter", category,
        "--logger", "trx;LogFileName=results.trx", "--results-directory", str(results), cwd=destination)
    root = ET.parse(results / "results.trx").getroot()
    counters = root.find(".//{*}Counters")
    if counters is None or int(counters.get("executed", "0")) == 0:
        raise RuntimeError(f"No tests executed for {label}; exit code zero is insufficient")
    if int(counters.get("passed", "0")) != int(counters.get("total", "0")):
        raise RuntimeError(f"Not all tests passed for {label}; inspect {results}")
    print(f"VERIFIED {label}: {counters.get('passed')} tests passed", flush=True)


def extract(path: Path) -> dict[str, str]:
    content = path.read_text(encoding="utf-8")
    return dict(re.findall(r"^## ([\w./-]+\.cs)\n\n```csharp\n(.*?)\n```", content, re.M | re.S))


def project(sdk: str, packages: str = "", references: str = "", tests: bool = False) -> str:
    return f'''<Project Sdk="{sdk}">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    {"<IsTestProject>true</IsTestProject>" if tests else ""}
  </PropertyGroup>
  <ItemGroup>{packages}{references}</ItemGroup>
</Project>
'''


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="New directory outside the target repository")
    parser.add_argument("--postgres", action="store_true", help="Also run PostgreSQL tests; requires SAMPLE_POSTGRES pointing to a disposable local test database")
    args = parser.parse_args()
    skill = Path(__file__).resolve().parents[1]
    destination = args.destination.resolve()
    # Refuse existing destinations, including empty ones; never overwrite user work.
    destination.mkdir(parents=True, exist_ok=False)

    def write(relative: str, content: str) -> None:
        path = destination / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    api = extract(skill / "references/example-create-product.md")
    if len(api) != 5:
        raise ValueError("Expected five named C# blocks in example-create-product.md")
    for name, code in api.items():
        if name == "Program.cs":
            code = code.replace("var app = builder.Build();", """builder.Services.AddScoped<Catalog.Contracts.ICatalogQueries, App.Api.Modules.Catalog.CatalogQueries>();
builder.Services.AddScoped<Orders.OrderProductReader>();
var app = builder.Build();""")
        write("App.Api/" + name, code + "\n")
    contracts = extract(skill / "references/example-module-contract.md")
    if len(contracts) != 3:
        raise ValueError("Expected three named C# blocks in example-module-contract.md")
    for name, code in contracts.items():
        write(name, code + "\n")

    write("Catalog.Contracts/Catalog.Contracts.csproj", project("Microsoft.NET.Sdk"))
    write("Orders/Orders.csproj", project("Microsoft.NET.Sdk", references='<ProjectReference Include="../Catalog.Contracts/Catalog.Contracts.csproj" />'))
    write("App.Api/App.Api.csproj", project("Microsoft.NET.Sdk.Web", packages='<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="10.0.0" />', references='<ProjectReference Include="../Catalog.Contracts/Catalog.Contracts.csproj" /><ProjectReference Include="../Orders/Orders.csproj" />'))
    write("App.Tests/App.Tests.csproj", project("Microsoft.NET.Sdk", packages='''
    <PackageReference Include="Microsoft.AspNetCore.Mvc.Testing" Version="10.0.3" />
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.14.1" />
    <PackageReference Include="xunit" Version="2.9.3" />
    <PackageReference Include="xunit.runner.visualstudio" Version="3.1.4" PrivateAssets="all" />
''', references='<ProjectReference Include="../App.Api/App.Api.csproj" />', tests=True))
    shutil.copytree(skill / "assets/example-tests", destination / "App.Tests", dirs_exist_ok=True)
    run("dotnet", "new", "sln", "--name", "Example", cwd=destination)
    run("dotnet", "sln", "add", "App.Tests/App.Tests.csproj", cwd=destination)
    run("dotnet", "restore", cwd=destination)
    run("dotnet", "build", "--no-restore", "-warnaserror", cwd=destination)
    test(destination, "Category!=Postgres", "without-database")
    if args.postgres:
        test(destination, "Category=Postgres", "postgres")
    else:
        print("NOT EXECUTED: PostgreSQL round-trip tests. Use --postgres with SAMPLE_POSTGRES.", flush=True)


if __name__ == "__main__":
    main()
