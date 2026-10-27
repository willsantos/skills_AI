# Guia de decisão por requisitos

## Primeiro elimine impossibilidades

| Condição | Consequência |
|---|---|
| Precisa de indexação de conteúdo dinâmico sem JavaScript | Priorizar SSR, SSG ou HTML servidor; SPA pura somente com estratégia demonstrada de prerender. |
| VPS limitada e funcionalidades apenas de dashboard | Avaliar Razor/Blazor SSR ou SPA estática + API; não introduzir servidor SSR só por conveniência. |
| Dependência pesada de biblioteca React-only | React+Vite ou Next.js, conforme SSR. |
| SEO de conteúdo público em Vue | Nuxt/SSR/SSG ou arquitetura híbrida. |
| Equipe extensa com exigência de convenções e arquitetura de UI explícita | Angular merece maior peso, mas não é obrigatório. |
| Apenas formulários/CRUD | Razor Pages pode reduzir contratos e deploy; não forçar SPA. |

## Critérios qualitativos

1. Qualidade de experiência (navegação, interatividade, acessibilidade, Web Vitals).
2. Rendering e SEO (CSR, SSR, SSG, páginas públicas vs privadas).
3. Complexidade para agentes (tipagem, estrutura, verificação, dependências).
4. Integração com .NET (OpenAPI, same-origin, cookie/CSRF, streaming).
5. Operação na VPS (processos, RAM, builds no CI, logs e rollback).
6. Custos de evolução (troca de stack, bibliotecas, recrutamento, maturidade).

**Não usar soma numérica sem pesos aceitos e evidência.** Uma única restrição eliminatória prevalece sobre médias arbitrárias.

## Topologias relevantes

- Razor/Blazor SSR + .NET: renderização no processo ASP.NET; servidores adicionais opcionais.
- Vue/Angular/React SPA: build estático + proxy de `/api` para ASP.NET na mesma origem; frontend não requer Node em produção.
- Next/Nuxt SSR: servidor de renderização + ASP.NET Core; arquitetura deliberada de sessão/BFF, observabilidade e cache.
- Apps híbridos: separar marketing público SSR/SSG e dashboard SPA, se operação extra compensar; não presumir que tudo exige SSR.

## Sinais para reconsiderar

- SEO real falha, Web Vitals ruins, limites de interação, bibliotecas incompatíveis.
- Equipe/agentes repetem erros no mesmo padrão apesar de testes e convenções.
- Operação de SSR/estados gera custo injustificado na VPS.
- Requisito novo comprovado, não preferência isolada por framework.
