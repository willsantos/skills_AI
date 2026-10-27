---
name: dotnet-vue-vite
description: "Desenvolver e manter frontends Vue 3 + Vite + TypeScript para APIs ASP.NET Core/.NET 10 em monólito modular + Vertical Slices: componentes, rotas, formulários, estado, consumo de OpenAPI, testes e deploy estático em VPS Linux. Use when implementar ou alterar features Vue com backend .NET; ler também dotnet-frontend-integration para contratos, autenticação, CSRF e infraestrutura. Do NOT use for lógica de backend .NET (usar dotnet-modular-vertical-slices), Angular/React/outros frameworks (sem skill dedicada neste pacote) ou escolha da arquitetura inicial (usar frontend-architecture-selector)."
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
  language: "pt-BR"
  frontend: "vue3-vite-typescript"
---

# Vue 3 + Vite + .NET

## Princípios

- **Vue 3 Composition API + `<script setup lang="ts">`**. Typescript `strict` e `vue-tsc` no CI. Usar versões do lockfile; não atualizar projeto existente sem motivação.
- **Organizar por feature/domínio**, não por camadas globais. Colocar componentes, composables, telas e testes próximos.
- **Backend é dono do domínio.** `src/api/generated` vem do OpenAPI, não editar a mão. Nenhuma regra de autorização/tenant depende apenas de UI.
- **Vue Router** para rotas e carregamento lazy. **Pinia** só para estado compartilhado de verdade, não para cada fetch/formulário. Reatividade local por `ref/computed` quando suficiente.
- Estados de carregamento/erro/vazio, acessibilidade, UX de sessão expirada, cancelamento de requisições e validação sem duplicar regras persistentes.
- **Vite build estático** para VPS; sem servidor Node em produção salvo ADR que exija SSR/Nuxt.

## Workflow obrigatório do agente

1. Ler ADR, feature do .NET correlata, schema OpenAPI, stack e testes existentes; respeitar componentes/padrões já escolhidos.
2. Construir uma feature vertical: route/page → component(s) → composable de UI, serviço/cliente tipado → testes. Evitar global stores genéricas.
3. Consumir DTOs gerados, tratar `ProblemDetails`, 401/403, 409, loading, retry/cancel quando necessário; usar same-origin `/api`.
4. Para login por cookie, aplicar proteção CSRF definida no backend; nunca salvar tokens sensíveis em localStorage por conveniência.
5. Rodar `vue-tsc --noEmit`, ESLint, testes de componente, E2E crítico e `vite build` via scripts do repositório. Relatar resultados reais.

## Estrutura sugerida

```text
web/
  src/
    app/                  # router, bootstrap, providers
    api/generated/        # código derivado de OpenAPI (não editar)
    features/
      projects/
        pages/
        components/
        composables/
        tests/
    shared/ui/            # componentes de apresentação reutilizados
```

## Não fazer

- Misturar Options API e Composition API em features novas sem justificativa.
- Copiar request/response do backend em interfaces TS manuais.
- Duplicar regras de preços, tenant, permissões ou persistência no browser.
- Criar store global por tela ou composable genérico para todas as requests.
- Fazer SSR por acidente, enviar secrets com `VITE_*`, implantar Vite dev server na VPS.

## Exemplos

### Exemplo 1 — nova feature de projetos

User says: "criar telas de CRUD de projetos no Vue consumindo o endpoint do módulo Projects".
Ações: ler schema OpenAPI e a feature .NET correlata; criar `features/projects` (página, componentes, composable, testes) com rota lazy; usar DTOs gerados e tratar `ProblemDetails`, loading e 401/403.
Resultado: feature vertical com `vue-tsc`, ESLint e testes executados via scripts do repositório.

### Exemplo 2 — login por cookie

User says: "o login será por cookie de sessão do ASP.NET".
Ações: seguir o esquema CSRF definido no backend conforme `dotnet-frontend-integration`; usar same-origin `/api`; não guardar tokens sensíveis em localStorage.
Resultado: sessão e CSRF funcionando de ponta a ponta sem estado de autenticação duplicado no browser.

## Referências

- Ler `references/patterns.md` quando estruturar features, decidir entre Pinia e estado local, ou escrever composables.
- Ler `references/dotnet-integration.md` ao configurar proxy Vite, gerar cliente OpenAPI ou preparar build estático para a VPS.
- Ler `evals/scenarios.md` antes de declarar a tarefa concluída, para conferir os cenários de avaliação.
- Para autenticação, contratos, API e VPS, ativar a skill `dotnet-frontend-integration`.
