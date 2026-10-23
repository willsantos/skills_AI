# AGENTS.md (modelo opcional para a raiz do repositório)

## Stack e arquitetura

- Backend: ASP.NET Core (seguir TargetFramework real do repo); Minimal APIs + módulos de negócio + Vertical Slices.
- Persistência: EF Core, com acesso direto ao DbContext quando suficiente.
- Regras de domínio nas entidades/value objects ou serviços de domínio, sem acoplar domínio ao transporte HTTP.
- Contratos HTTP explícitos, autorização por recurso e validação de entrada.
- Evitar MediatR/handlers/repositories/AutoMapper/interfaces sem problema concreto que justifique.

## Fluxo esperado

1. Ler a skill `dotnet-modular-vertical-slices` e inspecionar módulo/testes antes de escrever.
2. Entregar mudanças localizadas, com critérios de aceitação e contratos descritos.
3. Executar build/testes/analyzers; não ocultar falhas.
4. Informar migrations, contratos alterados, riscos e verificações não executadas.

## Comandos do projeto

- Restore: `dotnet restore`
- Build: `dotnet build --no-restore -warnaserror`
- Tests: `dotnet test --no-restore`
- Format check: `dotnet format --verify-no-changes --no-restore`

Personalize caminhos, nomes de soluções, ambiente de banco de testes e comandos para o repositório real. Não inserir aqui secrets ou URLs internas confidenciais.
