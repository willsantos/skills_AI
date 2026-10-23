# Executar exemplos e verificar comportamento

Ler ao alterar os exemplos ou comprovar funcionamento antes de publicar. `scripts/verify-example.py` extrai os blocos C# dos exemplos documentados, cria quatro projetos em diretório novo e executa testes de `assets/example-tests/`. Assim documentação compilada e código testado permanecem sincronizados.

## Pré-requisitos e execução sem banco

- Python 3, SDK .NET 10, runtime ASP.NET Core 10 e acesso ao NuGet. Pacotes estão fixados no script para reprodutibilidade, não são recomendação de versões para aplicações reais; revisar patches de segurança antes de reutilizar.
- Executar a partir de qualquer diretório, informando caminho da skill e um sandbox novo. Não executar na raiz de uma aplicação existente; script recusa destino já existente e não remove arquivos.

```bash
python3 dotnet-modular-vertical-slices/scripts/verify-example.py /tmp/opencode/dotnet-slices-example
```

Executa restore, build com warnings como erros e testes de domínio, HTTP inválido e contrato/fronteira modular. HTTP inválido usa endereço de banco sem serviço para comprovar rejeição antes da persistência. Não equivale a testar SQL ou sucesso HTTP. Registrar contagens; suíte PostgreSQL aparece explicitamente como não executada.

## PostgreSQL descartável

Usar somente banco local descartável, vazio, cujo nome termine em `_skill_tests`. Nunca fornecer connection string de produção. Testes criam schema/tabelas com `EnsureCreatedAsync` e inserem dados, mas não removem bancos/tabelas; esse mecanismo é apenas para sandbox, não substitui migrations nem teste de upgrade.

Exemplo opcional, após confirmar Docker disponível e porta local livre:

```bash
docker run --name dotnet-slices-example-pg -e POSTGRES_PASSWORD=example-only -e POSTGRES_DB=example_skill_tests -p 127.0.0.1:55432:5432 -d postgres:18
docker exec dotnet-slices-example-pg pg_isready -U postgres -d example_skill_tests
```

Esperar readiness antes de executar. Não reutilizar um contêiner/banco desconhecido. Senha acima é exclusivamente descartável de teste; não usar em deploy.

```bash
export SAMPLE_POSTGRES='Host=127.0.0.1;Port=55432;Database=example_skill_tests;Username=postgres;Password=example-only'
python3 dotnet-modular-vertical-slices/scripts/verify-example.py /tmp/opencode/dotnet-slices-example-pg --postgres
```

Se sandbox já existir, repetir testes sem regenerá-lo:

```bash
dotnet test /tmp/opencode/dotnet-slices-example-pg/App.Tests/App.Tests.csproj --filter 'Category=Postgres'
```

Não imprimir connection string em relatórios. Remoção de contêiner e dados requer decisão explícita do operador; script não faz limpeza destrutiva.

## Cobertura e limites

| Área | Evidência |
|---|---|
| Domínio | Nomes vazios/longos, preços zero/negativos, escala excedente, overflow, limites válidos |
| HTTP | 400 com Problem Details antes do acesso ao banco |
| SQL + HTTP | 201 e leitura em DbContext novo dos valores mínimo, comum e máximo |
| Módulos | Orders usa contrato, propaga cancelamento e não referencia implementação Catalog/EF |

Exemplo é catálogo público e sem tenant; não demonstra configuração de autenticação, autorização, migrations, outbox ou concorrência de atualização. Para aplicações protegidas, completar testes descritos em `quality-gates.md`. Para operações concorrentes e efeitos externos, seguir `consistency.md`. Não declarar cobertura dessas áreas com base nesta suíte.

## Diagnóstico

- Restore indisponível: registrar falha de rede/pacote; não afirmar compilação aprovada.
- Nenhum teste descoberto: verificar test SDK/runner, filtros e contagem; não aceitar exit code isolado como evidência.
- PostgreSQL indisponível: verificar readiness e porta; não trocar por InMemory para obter resultado verde.
- Destino existente: escolher outro diretório ou executar `dotnet test` no sandbox já gerado. Não apagar trabalho para contornar a proteção.

## Fontes

- [Testes de integração ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests).
- [Estratégia de testes EF Core](https://learn.microsoft.com/en-us/ef/core/testing/choosing-a-testing-strategy).
- [Precisão e escala EF Core](https://learn.microsoft.com/en-us/ef/core/modeling/entity-properties#precision-and-scale).
- [Tipos numéricos PostgreSQL](https://www.postgresql.org/docs/current/datatype-numeric.html).
