---
name: dotnet-modular-vertical-slices
description: "Desenvolver, revisar e manter backends ASP.NET Core/.NET com Monólito Modular, Vertical Slices, Minimal APIs, EF Core e DDD pragmático. Use when criar módulos, implementar endpoints, revisar fronteiras de domínio, refatorar slices ou alterar queries, migrations, testes, integrações e jobs nesse contexto. Do NOT use for frontends, aplicações não .NET, dúvidas genéricas de C# sem contexto de backend ou administração de VPS sem relação com uma aplicação .NET."
compatibility: "Agentes com acesso ao repositório e comandos .NET; .NET 10 é a referência, adaptar à versão instalada."
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
  language: "pt-BR"
  architecture: "modular-monolith-vertical-slices"
---

# .NET Modular Monolith + Vertical Slices

## Objetivo

Implementar a menor solução **correta, verificável e sustentável**, organizada por módulos de negócio e operações (slices), preservando regras de domínio e integridade de dados. Preferir composição direta a abstrações de passagem; nunca sacrificar testes, segurança ou fronteiras modulares por menos linhas de código.

## Quando ativar

- Criar projeto ASP.NET Core, novos módulos, features ou endpoints.
- Alterar/refatorar funcionalidades existentes ou revisar decisões arquiteturais.
- Implementar persistência EF Core, validação, eventos, workers, integrações ou deploy Linux.
- Não converter uma arquitetura existente automaticamente: primeiro entender e respeitar as decisões do repositório; propor migração incremental se necessário.

## Contexto e fontes de verdade

1. Ler `AGENTS.md`, documentação, `global.json`, `.sln/.slnx`, `.csproj`, `Program.cs`, módulos afetados e testes **antes** de alterar código.
2. Seguir requisitos do usuário e padrões reais do projeto; não inventar endpoints, invariantes, entidades, migrations ou contratos.
3. Se houver ambiguidade que altere dados, segurança ou API pública, expor a suposição e confirmar antes de uma mudança irreversível. Para escolhas reversíveis, optar pelo padrão mais simples já existente.
4. Consultar documentação atual da versão real do projeto quando APIs/pacotes estiverem incertos. Não presumir que .NET 10, EF Core 10 ou bibliotecas extras já estejam instalados.

## Regras arquiteturais obrigatórias

1. **Módulo = capacidade de negócio** (`Catalog`, `Orders`, `Billing`), não pasta técnica global (`Services`, `Repositories`, `Dtos`).
2. **Slice = operação completa** (`CreateOrder`, `GetOrder`, `CancelOrder`): reunir contrato HTTP, validação e caso de uso próximo um do outro, com testes específicos.
3. **Domain é protegido:** invariantes de entidades e value objects devem sobreviver a qualquer entrada (endpoint, job ou evento). Não colocar regras de negócio exclusivamente em controllers/endpoints.
4. **Persistência direta quando simples:** usar `DbContext`/EF Core no caso de uso; não criar `IRepository<T>`, UnitOfWork, handlers, MediatR ou AutoMapper sem necessidade demonstrada.
5. **Interfaces só em fronteiras reais:** provedores externos, clock, storage, gateways e políticas com implementações variáveis; injeção de classes concretas é permitida. Não abolir DI nativa.
6. **Contratos explícitos nas bordas:** Request/Response não expõem entidades EF; validar entradas, autorização, ownership/tenant, limites de paginação e serialização. Preferir projeção LINQ direta a mappings em cascata.
7. **Acesso entre módulos apenas por contratos públicos:** não consultar DbSet, tabelas, entidades internas ou serviços privados de outro módulo. Uma única base física não elimina ownership lógico.
8. **Não acoplar tudo em `Common`:** compartilhar apenas infraestrutura transversal realmente reutilizada; não construir `BaseService`, `GenericRepository` ou Helpers genéricos preventivos.
9. **CQRS pragmático:** separar leituras e escritas por operação; sem dois modelos físicos, message bus ou mediator como obrigação.
10. **Evolução incremental:** manter monólito de implantação única inicialmente; separar projetos por módulos, bounded contexts, outbox ou workers apenas quando requisitos concretos justificarem.

## Fluxo de trabalho do agente

1. **Inspecionar:** identificar módulo responsável, slices parecidos, contratos, schema, autenticação, testes e riscos. Usar `references/workflow.md`.
2. **Planejar em poucas linhas:** comportamento solicitado, arquivos afetados, mudanças de schema, testes e pontos de risco. Não criar estrutura extra sem motivo.
3. **Implementar uma slice vertical:** entrada → autorização/validação → caso de uso → domínio → persistência/integrações → resposta. Manter coesão, responsabilidades e nomenclatura.
4. **Testar falha e sucesso:** testes de unidade das invariantes, integração com banco para queries/escritas, HTTP/autorização e isolamento de módulos conforme alcance da mudança.
5. **Verificar:** `dotnet restore`, `dotnet build`, `dotnet test` e ferramentas do repositório quando disponíveis. Executar format/analyzers e checar OpenAPI/migrations quando aplicável. Não afirmar que passou sem executá-los.
6. **Relatar:** resumo de alterações, contratos alterados, migrations, testes executados/resultados e riscos/limitações não verificados.

## Decisões rápidas

| Problema | Preferir | Evitar por padrão |
|---|---|---|
| API web | Minimal APIs + grupos de rotas por módulo | Controller + service + handler obrigatórios |
| CRUD simples | Endpoint/feature + EF Core | Repository genérico e MediatR apenas para encaminhar |
| Consulta | `AsNoTracking()` + `Select(Response)` + paginação | Carregar entidade inteira e mapear em série |
| Regra compartilhada | Método na entidade/value object ou serviço de domínio | Copiar validações entre endpoints |
| Dependência externa | Interface específica + implementação DI | Interface para cada classe local |
| Comunicação entre módulos | Contrato explícito, serviço público ou evento justificado | Ler diretamente tabelas/DbContext de outro módulo |
| Tarefa longa | Worker/fila e idempotência | Manter requisição HTTP aberta sem necessidade |
| Evolução estrutural | Introduzir camada/projeto quando há benefício mensurável | Antecipar Clean Architecture completa |

## Cuidados não negociáveis

- Não executar `database update`, migrations destrutivas, `docker compose down -v`, limpeza de banco, deploy ou alterações em produção sem autorização explícita.
- Nunca hardcodar secrets, tokens, senhas, chaves ou connection strings de produção.
- `DbContext` não é thread-safe: cada operação concorrente/worker usa scope/instância própria; `await` em todas as operações EF.
- Respeitar cancelamento, idempotência em webhooks/jobs, controle de acesso por recurso/tenant, transações e concorrência quando relevantes.
- Testes não devem depender de credenciais de produção. Incluir políticas de erro, logs estruturados e dados sensíveis protegidos.
- Não criar dependências novas nem atualizar versões sem explicar o benefício e verificar compatibilidade.

## Referências sob demanda

- **Estrutura, fronteiras e critérios para abstração:** `references/architecture.md`.
- **Fluxo de implementação e revisão:** `references/workflow.md`.
- **Exemplo de feature .NET + EF Core:** `references/example-create-product.md`.
- **Verificações, segurança e testes:** `references/quality-gates.md`.
- **Deploy em VPS Linux:** `references/linux-vps.md`.
- **Modelo de instruções para repositório:** `assets/AGENTS.example.md`.
- **Script opcional de verificação:** `scripts/verify-dotnet.sh`.
- **Avaliação da skill:** ler `evals/scenarios.md` ao alterar estas instruções ou verificar ativação, limites de escopo e aderência do agente.

## Exemplos de uso

- **Pedido:** "Adicione CreateProduct em Catalog". **Resultado esperado:** slice com Request/Response, validação, invariantes de domínio, persistência EF e testes; sem camadas de passagem.
- **Pedido:** "Orders precisa mostrar o nome do produto". **Resultado esperado:** consultar contrato público de Catalog, sem acessar suas tabelas ou entidades internas.
- **Pedido:** "Adicione uma feature neste backend que já usa Controllers". **Resultado esperado:** seguir o padrão existente, sem converter automaticamente para Minimal APIs.

## Falhas de verificação

- Se SDK, banco de testes ou dependências não estiverem disponíveis, informar comando bloqueado e motivo; não declarar build ou testes aprovados.
- Se build ou testes falharem, registrar falha, corrigir apenas o que estiver no escopo e repetir as verificações afetadas; não ocultar erros com flags ou remover testes.

**Regra final:** menos classes não é objetivo por si só. O objetivo é obter menos pontos de falha, menos decisões arbitrárias para o agente e mais comportamento comprovadamente correto.
