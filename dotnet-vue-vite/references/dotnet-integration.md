# Vue/Vite integrado a ASP.NET Core

## Desenvolvimento local (exemplo adaptável)

`vite.config.ts` (ajustar porta do ASP.NET):

```ts
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    proxy: { '/api': { target: 'http://localhost:5080', changeOrigin: true } },
  },
})
```

`/api` permanece **relativa** no browser. O proxy é para dev; em produção Caddy/Nginx encaminha `/api` ao .NET.

## OpenAPI → TypeScript (uma opção leve)

```sh
npm install openapi-fetch
npm install --save-dev openapi-typescript
npx openapi-typescript openapi/v1.json -o src/api/generated/schema.d.ts
```

Cliente tipado (o arquivo do contrato `schema.d.ts` precisa existir):

```ts
import createClient from 'openapi-fetch'
import type { paths } from './generated/schema'

export const api = createClient<paths>({ baseUrl: '' })
// Exemplo: api.GET('/api/projects') SOMENTE se existir no OpenAPI.
```

Se o projeto já usa outro gerador de cliente, respeitar o padrão presente. Fixar versões, gerar OpenAPI do .NET em CI e falhar em drift.

## Cookies e CSRF

Browser usa cookies same-origin nas configurações normais; implementar XSRF compatível com ASP.NET antes de usar endpoints mutáveis autenticados. `openapi-fetch` não configura automaticamente todo mecanismo de CSRF. Não transferir tokens de sessão para localStorage.

## Qualidade e deploy

- `npm ci`, `npm run lint`, `npx vue-tsc --noEmit`, `npm run test`/`test:e2e` (conforme scripts existentes), `npm run build`.
- Build padrão Vite sai em `dist/`; servir esses arquivos com Caddy ou Nginx e encaminhar `/api` para .NET. Nunca `vite preview` como servidor de produção.
- `VITE_*` é embutido no JS público. Não colocar chave privada nem connection string.

Consultar `dotnet-frontend-integration/references/auth-and-security.md` e `vps-linux.md`.
