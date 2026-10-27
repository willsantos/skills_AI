---
name: frontend-architecture-selector
description: "Selecionar e justificar a arquitetura de frontend para produtos com ASP.NET Core (Razor Pages, Blazor, Vue/Vite, Angular, React/Vite, Next.js ou Nuxt), considerando requisitos reais, agentes de programação, SEO, interatividade e publicação em VPS Linux. Use when iniciar um produto novo, avaliar troca de frontend ou comparar arquiteturas; registrar ADR e não redecidir a cada feature. Do NOT use para implementar features (usar a skill do framework escolhido), reabrir a stack vigente de projeto existente sem pedido explícito de migração, ou decidir backend .NET (usar dotnet-modular-vertical-slices)."
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
  language: "pt-BR"
  context: "dotnet-10-vps-linux"
---

# Seletor de arquitetura de frontend

## Regra central

Escolher **a opção de menor complexidade que cumpra requisitos verificáveis**. Não assumir React/Next.js por popularidade, Angular por tamanho, Vue por simplicidade ou Razor por usar C#. Não apresentar pontuação subjetiva como benchmark.

## Procedimento

1. Inspecionar documentação, ADRs, frontend existente, .NET API, restrições de VPS e requisitos. Se projeto existente, **preservar stack vigente** salvo ordem de migração ou impedimento demonstrado.
2. Identificar requisitos eliminatórios e prioridades: SEO/indexação pública, SSR real, SPA/interatividade, off-line, estado, formulários, SEO social, acessibilidade, hospedagem, autenticação e tamanho da equipe/uso por agentes.
3. Comparar ao menos duas candidatas viáveis; calcular serviços **em produção**, não apenas linguagens de desenvolvimento. Distinguir SPA estática de SSR e BFF.
4. Escolher stack e modo de rendering/deploy, documentar alternativas, trade-offs, riscos e condições de reavaliação em ADR (`assets/adr-template.md`).
5. Ativar skill `dotnet-frontend-integration` e a implementação disponível (`dotnet-vue-vite` ou `dotnet-angular`). Para outros frontends, indicar que a skill dedicada ainda não está neste pacote.
6. Não introduzir novo framework, runtime SSR, estado global, BFF ou Node em produção sem uma necessidade concreta.

## Heurísticas iniciais (não são imposições)

- **Razor Pages:** fluxos orientados a páginas e formulários, renderização HTML no servidor, pouca necessidade de SPA.
- **Blazor:** priorizar C# na UI; escolher conscientemente entre SSR estático, interatividade no servidor e WebAssembly (estado, conexões, payload).
- **Vue + Vite:** SPA rica, backend .NET separado, artefatos estáticos e simplicidade operacional.
- **Angular:** muitas funcionalidades e convenções consistentes, equipes/agents com forte padronização; aceita maior curva conceitual.
- **React + Vite:** SPA que exige bibliotecas e componentes específicos de React, sem necessidade real de SSR.
- **Next.js:** React com SSR/híbrido, streaming, SEO dinâmico ou BFF deliberado. Evitar duplicar backend de domínio.
- **Nuxt:** Vue com SSR/híbrido ou geração de páginas públicas dinâmicas. Evitar duplicar backend de domínio.

## Questões obrigatórias antes da decisão

- O conteúdo principal deve ser indexado sem executar JS? Há SSR/SSG/prerender adequado?
- A interface é majoritariamente formulários ou altamente interativa? Há editores, DnD, tempo real ou offline?
- O app é um dashboard autenticado, um site público, ou ambos? Pode separar área pública/privada?
- Qual infraestrutura real da VPS (RAM, CPU, disco, múltiplos serviços)? Haverá Node em produção?
- Quais bibliotecas específicas são realmente exigidas? É possível gerar a SPA estaticamente?
- Quem mantém os contratos? Como proteger mudanças por agentes (typecheck, CI, OpenAPI, testes)?

## Saída exigida

ADR curto e acionável: contexto, requisitos eliminatórios, candidatos, decisão, topologia VPS, custos operacionais esperados sem números inventados, riscos, critérios para rever, plano de verificação. Se a informação crítica faltar, explicitar a hipótese e apontar validação antes de compromisso irreversível.

## Exemplos

### Exemplo 1 — produto novo, área autenticada

User says: "vou construir um SaaS B2B com backend .NET; qual frontend uso?".
Ações: confirmar requisitos (área privada, formulários densos, sem SEO público, VPS única); comparar ao menos duas candidatas em serviços de produção; registrar ADR com `assets/adr-template.md`.
Resultado: decisão documentada (ex.: SPA estática Vue ou Angular + `/api` same-origin) com critérios de reavaliação, sem Node em produção.

### Exemplo 2 — site público com SEO

User says: "o produto é um site público que precisa indexar bem no Google".
Ações: verificar SSR/prerender reais nas candidatas e custo operacional do runtime na VPS; se nenhuma exigência eliminatorária justificar SPA, preferir a opção de menor complexidade.
Resultado: ADR apontando a topologia escolhida e o problema de SEO tratado por requisito verificado, não por preferência de framework.

Se requisitos conflitarem ou faltar informação crítica (problema comum), registrar a hipótese adotada e a validação pendente no próprio ADR antes de qualquer compromisso difícil de reverter.

## Material adicional

- Ler `references/decision-guide.md` quando os requisitos não eliminarem candidatas por si sós e for preciso critérios, matriz comparativa e armadilhas por stack.
- Copiar `assets/adr-template.md` ao registrar a decisão em `docs/adr/`.
- Ler `evals/scenarios.md` antes de entregar a decisão, para conferir os cenários de teste do seletor.
