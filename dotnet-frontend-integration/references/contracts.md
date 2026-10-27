# Contratos HTTP e erros

## Fonte de verdade e geração

- Analisar Minimal APIs e seus `Request`/`Response` no .NET. Expor OpenAPI com `Microsoft.AspNetCore.OpenApi` (`AddOpenApi`, `MapOpenApi` restrito a desenvolvimento/ambiente aprovado). Produção não precisa expor schema publicamente.
- Gerar `openapi/v1.json` em CI com mecanismo suportado pelo projeto (`Microsoft.Extensions.ApiDescription.Server` no build ou rota protegida em ambiente de build).
- Clientes: Vue pode usar `openapi-typescript` + `openapi-fetch`; Angular pode usar gerador `typescript-angular`/equivalente integrado a `HttpClient`. Fixar versões de geradores e conferir compatibilidade.
- Código gerado fica isolado em `src/api/generated/` (não editar). Wrappers de feature são pequenos; evitar duplicar schemas/tipos de requests/responses manualmente.
- Falhar CI quando regeneração produzir diff inesperado, com revisão explícita de alterações incompatíveis.

## Semântica

- Descrever claramente `200`, `201`, `204`, `400`/`422`, `401`, `403`, `404`, `409`, `429` e `5xx` relevantes; não forçar todos em todo endpoint.
- `401` = não autenticado; `403` = autenticado sem permissão; `404` opcional para não expor existência de recurso; `409` conflitos de concorrência/regra.
- Validação retorna objeto estável de erros de campo; UI acessível mostra feedback e preserva estado do formulário.
- `DateTimeOffset`/UTC, precisão monetária, enum e paginação devem ter semântica explícita; não inferir tipos no browser.
- Para mudanças que quebram contrato, documentar compatibilidade, versão e sequência de deploy frontend/backend.

## Exemplo mínimo ASP.NET Core (.NET 10)

```csharp
builder.Services.AddOpenApi();
var app = builder.Build();
if (app.Environment.IsDevelopment()) app.MapOpenApi();
// Mapear módulos e rotas conforme dotnet-modular-vertical-slices
app.Run();
```

Este trecho é ilustrativo; o pacote `Microsoft.AspNetCore.OpenApi` deve estar referenciado e a ordem completa de middlewares deve seguir a aplicação.

Fonte: https://learn.microsoft.com/en-us/aspnet/core/fundamentals/openapi/aspnetcore-openapi?view=aspnetcore-10.0
