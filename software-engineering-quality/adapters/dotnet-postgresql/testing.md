# Adapter .NET: testes de integração reais

## Ferramentas e escopo

- `xUnit` ou framework já adotado; não trocar ferramenta apenas por preferência.
- `Microsoft.AspNetCore.Mvc.Testing` / `WebApplicationFactory<Program>` para HTTP + pipeline real.
- `Testcontainers.PostgreSql` ou PostgreSQL de teste isolado para SQL real.
- `Microsoft.EntityFrameworkCore` com migrations de produção, sem `EnsureCreated` substituindo migrations.
- `Playwright` para jornadas reais de browser quando necessário (separate suite).

## Fixture recomendada

1. Iniciar PostgreSQL isolado (Testcontainers) e obter connection string.
2. Construir `WebApplicationFactory<Program>` substituindo a configuração de `DbContext`/connection string no ambiente de teste. Evitar remover dependências usadas em outros serviços sem ajustar o registro.
3. Aplicar migrations reais antes de executar cenários, usando escopo do container de DI de teste.
4. Criar dados explicitamente por cenário; autenticar cliente com mecanismo de teste controlado, simulando somente a identidade e não a autorização que será testada.
5. Criar clientes HTTP diferentes e conexões reais distintas para testes de corrida.
6. Encerrar factory/container sem deixar estado compartilhado entre suítes.

Para Minimal APIs com classe `Program` implícita, o projeto pode expor `public partial class Program { }` ou usar `InternalsVisibleTo` de forma compatível com a versão da aplicação.

## Esqueleto de teste comportamental

```csharp
[Fact]
public async Task LastUnit_CannotBeSoldTwice()
{
    // Arrange: migrar DB real e inserir produto com Stock = 1.
    // Act: duas requisições HTTP simultâneas, sincronizadas
    //      por barrier quando necessário para testar a disputa.
    // Assert: exatamente 1 sucesso e 1 recusa.
    // Assert: produtos.stock == 0; número de reservas == 1.
    // Nota: caso necessário, repetir sob um agendador controlado
    //       e usar conexões distintas. Task.WhenAll sozinho não
    //       prova que ocorreu o interleaving problemático.
}
```

O esqueleto é intencionalmente incompleto: adapte ao contrato real, dados e fixtures existentes. Nunca reportar este exemplo como teste implementado.

## Casos prioritários para uma Vertical Slice de pedido

| Caso | Verificações |
| --- | --- |
| `CreateOrder` sucesso | HTTP esperado, pedido/itens persistidos, preço do banco |
| Preço adulterado | campos privilegiados ignorados/rejeitados, total correto |
| Estoque insuficiente | erro estável, zero pedido, zero reserva |
| Duas compras da última unidade | 1 aprovada, 1 rejeitada, estoque 0 |
| Falha no insert do pedido | rollback de reserva, nenhuma alteração parcial |
| GET de pedido de outro usuário | 404/403 conforme política, nenhuma exposição |
| Webhook repetido | apenas um efeito/um evento por ID |
| Webhook fora de ordem | nenhum estado inválido/retrocesso indevido |

## CI

- Executar testes unitários em cada alteração; testes de integração em PRs, quando viável com container.
- Separar testes lentos de teste de unidade sem remover o gate crítico.
- Relatar falhas reais, skip por falta de Docker e flakiness. Não substituir teste crítico por mock para melhorar tempo.
- Se usar ambiente VPS com Docker, isolar rede/credenciais de teste de produção.

Referências: https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests ; https://dotnet.testcontainers.org/modules/postgres/
