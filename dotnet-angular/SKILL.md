---
name: dotnet-angular
description: "Desenvolver e manter Angular 22 standalone + TypeScript integrando APIs ASP.NET Core/.NET 10: features, signals, HttpClient, OpenAPI, autenticação/CSRF, testes e deploy estático em VPS Linux. Use when criar ou alterar componentes, rotas, serviços, formulários, estado ou testes de um frontend Angular com backend .NET, junto da skill dotnet-frontend-integration. Do NOT use for lógica de backend .NET (usar dotnet-modular-vertical-slices), Vue/React/outros frameworks (sem skill dedicada neste pacote) ou escolha da arquitetura inicial (usar frontend-architecture-selector)."
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
  language: "pt-BR"
  frontend: "angular-22"
---

# Angular 22 + ASP.NET Core

## Princípios

- **Angular 22** como linha de referência de outubro de 2026; em projetos existentes seguir a versão instalada/suportada.
- Preferir **standalone components**, `inject()`, **signals/computed** para estado de UI síncrono e controle de fluxo moderno. Não migrar toda aplicação antiga com NgModules sem solicitação.
- Organização **por feature**: rotas, componente, API adapter, estado e testes próximos. Não centralizar todas as classes em `components/` e `services/` globais.
- **`HttpClient` configurado em `provideHttpClient()`**, interceptors funcionais quando necessários. O Angular 22 possui `HttpClient` disponível para injeção por padrão, mas configuração explícita continua útil para interceptors/XSRF.
- OpenAPI do backend .NET é a fonte de verdade; gerar cliente Angular/DTOs, nunca duplicar contratos manualmente.
- Formulários, navegação e permissões de UI não substituem verificação backend por tenant/recurso.
- **SPA estática em VPS** inicialmente; SSR/híbrido apenas por ADR e necessidade de SEO/performance.

## Workflow do agente

1. Ler `angular.json`, `package.json`, `tsconfig`, ADR, feature existente, testes e OpenAPI atual.
2. Criar feature orientada a operação, configurar lazy routes com `loadComponent`/`loadChildren` quando adequado, limitar escopo dos providers.
3. Consumir cliente OpenAPI gerado; configurar interceptors e UX consistente para `ProblemDetails`, erros de campo, loading, 401/403, cancelamento e acessibilidade.
4. Para cookies, configurar proteção XSRF no backend ASP.NET; Angular sozinho não valida tokens. Usar same-origin `/api`.
5. Rodar scripts reais `ng build`, typecheck/Angular compiler, linter configurado, unit tests e E2E; declarar o que não executou.

## Estrutura sugerida

```text
web/src/app/
  app.config.ts
  app.routes.ts
  api/generated/             # gerador, não editar
  features/
    projects/
      pages/
      components/
      data-access/
      projects.routes.ts
  shared/ui/                 # só componentes realmente compartilhados
```

## Evitar

- Criar `NgModule` e serviços de DI para cada componente novo por hábito.
- Duplicar DTOs, regras de domínio, authorization e acesso direto ao banco.
- Misturar vários sistemas de estado ou streams RxJS sem motivo; `signals` não substituem por si só requests HTTP.
- Guard de rota como mecanismo de segurança; ele é apenas UX.
- Rodar servidor Angular CLI em produção; secrets em `environment.ts` ou no bundle.

## Exemplos

### Exemplo 1 — nova tela de listagem

User says: "criar uma página de projetos no Angular consumindo a API existente".
Ações: ler OpenAPI e feature vizinha; replicar o padrão `features/<nome>/data-access` com signals; criar rota lazy; tratar loading, `ProblemDetails` e 401/403; rodar `ng build` e testes.
Resultado: feature vertical entregue com testes executados e relatório do que não foi verificado.

### Exemplo 2 — formulário com cookie auth

User says: "adicionar um formulário de criação de projeto; o login é por cookie".
Ações: confirmar com `dotnet-frontend-integration` o esquema XSRF definido no backend; usar `HttpClient` same-origin `/api`; validar erros de campo retornados pela API.
Resultado: formulário funcionando com CSRF coberto pelo par backend+frontend, sem duplicar validação de domínio.

## Referências

- Ler `references/patterns.md` quando criar componentes, rotas lazy ou organizar features por domínio.
- Ler `references/dotnet-integration.md` ao gerar/consumir cliente OpenAPI, configurar XSRF ou preparar deploy estático.
- Ler `evals/scenarios.md` antes de declarar a tarefa concluída, para conferir os cenários de avaliação.
- Para contratos, autenticação, CSRF e infraestrutura de VPS, ativar a skill `dotnet-frontend-integration`.
