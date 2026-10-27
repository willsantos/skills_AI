# VPS Linux: SPA estática + ASP.NET Core

## Topologia simples

`HTTPS público → Caddy/Nginx → /api/* ASP.NET Core (loopback:8080); demais rotas → dist estático`.

Apenas ASP.NET é processo de aplicação; **Vite dev server e Angular CLI não rodam em produção**. Gere o build no CI e copie os arquivos finais para diretório imutável/versão de release. Next/Nuxt SSR são topologia diferente, com runtime de servidor, se selecionados pela ADR.

## Checklist de deploy

1. `dotnet restore --locked-mode` se lock configurado, `dotnet build`, `dotnet test`.
2. Frontend: `npm ci`, lint, typecheck, testes, build (`npm run build` ou comando real no package.json). Para Angular, conferir `outputPath` no `angular.json`; nem sempre é `dist/` diretamente.
3. Verificar artefatos imutáveis e parâmetros de ambiente; `VITE_*` vira informação **pública** compilada no JS. Não colocar segredos em variáveis frontend.
4. Reverse proxy roteia `/api/*` **antes** do fallback SPA. Rotas de API inexistentes devem retornar 404 da API, não `index.html`.
5. HTTPS automático; headers de segurança adequados; cache forte para arquivos fingerprintados e **sem cache agressivo** de `index.html`.
6. ASP.NET exposto somente em loopback/rede privada; PostgreSQL não exposto à internet; backup externo e restore testado.
7. Health check e logs; rollback de binários/arquivos com cuidado especial para compatibilidade do schema de banco.
8. Build e deploy por CI, evitando compilar pesado na VPS pequena.

## Desenvolvimento

Frontend com proxy `/api` para a API local. Isso dá experiência same-origin e evita mudar configurações de CORS para cada porta. Porta/host devem ser configurados conforme projeto.

Referências: https://vite.dev/guide/static-deploy ; https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/?view=aspnetcore-10.0
