---
name: dotnet-frontend-integration
description: "Integrar frontends Razor, Blazor, Vue, Angular, React, Next ou Nuxt a ASP.NET Core/.NET 10, com OpenAPI como contrato, autenticação por cookies/sessão ou tokens apropriados, CSRF/CORS, erros ProblemDetails, streaming e deploy em VPS Linux. Use when criar ou alterar cliente de API, autenticação, SSR/BFF, proxy, ambiente, contratos, tempo real, build e publicação. Do NOT use para implementar features de um framework específico (usar dotnet-vue-vite ou dotnet-angular), lógica de domínio ou backend .NET (usar dotnet-modular-vertical-slices), ou escolha da arquitetura inicial (usar frontend-architecture-selector)."
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
  language: "pt-BR"
  backend: "dotnet-modular-vertical-slices"
---

# Integração segura de frontend com ASP.NET Core

## Responsabilidades

- O **backend .NET é dono** das regras de domínio, integridade, autorização por recurso/tenant, validação e persistência.
- O frontend é dono de UX, renderização, navegação, estado de apresentação e validação antecipada de formulários (não substitui servidor).
- **OpenAPI é a fonte canônica** de contratos HTTP publicados pelo .NET. Gerar tipos/cliente para SPA; não manter DTOs duplicados à mão.
- Em Razor/Blazor Server, chamadas internas não precisam passar artificialmente por HTTP; preservar regras e casos de uso dos módulos.

## Fluxo obrigatório

1. Inspecionar `.NET` API/endpoint, ADR de frontend, auth/tenancy, OpenAPI, pipeline de build, reverse proxy e cliente atual.
2. Especificar operação com métodos, schemas, status codes, paginação, erros, autorização, timeout/cancelamento e observabilidade; não inventar endpoints.
3. Gerar/atualizar OpenAPI com fonte aprovada. Regenerar cliente tipado; falhar CI em drift de contrato; revisar breaking changes.
4. Padronizar origem: **preferir same-origin** (ex.: `/` estático, `/api` no .NET) em VPS. Se cross-origin inevitável, permitir apenas origens confiáveis com configuração explícita.
5. Definir modelo de autenticação e CSRF antes do código; teste 401/403/422 (ou 400 conforme API) e controle por recurso.
6. Testar ponta a ponta login, expiração, refresh quando houver, erros, acesso negado, streaming, upload e deploy quando aplicáveis.
7. Documentar alterações, comandos executados e limites da verificação. Não publicar/alterar produção sem autorização.

## Segurança inegociável

- **Não armazenar access/refresh tokens sensíveis no localStorage** como padrão; avaliar cookie HttpOnly Secure + BFF/sessão server-side, considerando as ameaças e a topologia.
- Cookie auth em requests mutáveis exige defesa CSRF compatível com o .NET; **CORS não é substituto universal** de CSRF. Angular envia cabeçalhos XSRF por convenção, mas o backend deve gerar e verificar os tokens/cabeçalhos.
- Evitar `AllowAnyOrigin` combinado a credenciais. Cookies `Secure`, `HttpOnly` para sessão, `SameSite` adequado, HTTPS, logout/expiração. Nunca expor secrets ao bundle da SPA.
- O UI pode ocultar botões, mas authorization (resource/tenant) é sempre do .NET; verificar IDOR.
- `ProblemDetails`/erros tipados sem stack trace e dados pessoais em produção; cookies/headers sensíveis não registrados.
- Webhooks e jobs devem validar assinaturas/idempotência; não mover lógica de negócio para SSR/BFF.

## Decisões rápidas

| Situação | Padrão |
|---|---|
| SPA em VPS única | Proxy same-origin com `/api` → ASP.NET, `/` → arquivos estáticos. |
| Vue/Vite ou Angular | Cliente gerado do OpenAPI, base URL relativa, build estático no CI. |
| Next/Nuxt SSR | BFF somente se deliberado; evitar regras de negócio duplicadas e tratar cookies/cache com cuidado. |
| Razor/Blazor SSR | Usar chamadas diretas a serviços internos em escopo correto; evitar HTTP para a própria aplicação. |
| Erros de API | RFC 9457 Problem Details (ou formato vigente), status e campos estáveis, mapear para UX. |
| Realtime | SSE para stream unidirecional simples; SignalR/WebSocket quando comunicação bidirecional exigir. |
| Arquivos | Limite de tamanho, autenticação, verificação de conteúdo, armazenamento externo se necessário. |

## Exemplo

User says: "o frontend Vue precisa fazer login e consumir a API do módulo Projects".
Ações: confirmar autenticação por cookie HttpOnly + CSRF do ASP.NET; regenerar cliente OpenAPI e falhar CI em drift; padronizar same-origin `/api` no proxy; testar login, expiração, 401/403 e `ProblemDetails` de ponta a ponta.
Resultado: integração documentada com contratos gerados, segurança definida pelo backend e verificação real executada.

## Referências sob demanda

- Ler `references/contracts.md` ao definir ou versionar contratos OpenAPI e avaliar breaking changes.
- Ler `references/auth-and-security.md` ao decidir cookies vs tokens, CSRF, CORS e autorização por recurso.
- Ler `references/vps-linux.md` ao configurar proxy reverso, CI e publicação na VPS; ver `assets/Caddyfile.example` para roteamento SPA estática + .NET.
- Ler `references/realtime.md` quando houver streaming, SSE, SignalR ou filas.
- Ler `evals/scenarios.md` antes de declarar a integração concluída, para conferir os cenários de cumprimento.
