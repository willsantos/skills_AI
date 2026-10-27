# Angular ↔ ASP.NET Core

## Configuração HTTP (exemplo)

`app.config.ts` (assume standalone e Angular moderno):

```ts
import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { apiErrorInterceptor } from './shared/http/api-error.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    provideHttpClient(withInterceptors([apiErrorInterceptor])),
  ],
};
```

`apiErrorInterceptor` é um arquivo **do projeto** que deve existir; não criar interceptor vazio apenas para satisfazer exemplo. Não interceptar refresh/login com lógica circular.

## SDK OpenAPI

O ASP.NET Core deve gerar `openapi/v1.json`. Utilizar gerador configurado e versionado para Angular (ex.: gerador `typescript-angular` do OpenAPI Generator) e incluir seu código gerado em `api/generated/`. Alguns geradores requerem Java no ambiente de build; fixar versão/infra em CI. **Não inventar nomes dos métodos gerados**; ler o código e contrato antes de usá-lo. Adaptadores `data-access/` podem esconder detalhes de transporte sem refazer todo DTO.

## Cookies/XSRF

`HttpClient` oferece convenção XSRF (`XSRF-TOKEN` → `X-XSRF-TOKEN`) para mutações same-origin, mas o ASP.NET Core precisa **emitir e validar** o token correto, além de definir cookie/session policies. Se nomes divergirem, configurar `withXsrfConfiguration` de modo explícito. Verificar o fluxo real, inclusive `POST/PUT/PATCH/DELETE` e login. Não depender só de CORS ou de guards.

## Desenvolvimento e VPS

- Dev: configurar `proxyConfig` do Angular dev server para encaminhar `/api` a uma API ASP.NET local, evitando CORS desnecessário. Consultar sintaxe da versão Angular instalada.
- Produção: `ng build` gera assets estáticos; conferir `angular.json` (`outputPath`, normalmente `dist/<app>/browser` nos builders modernos). Servir com Caddy/Nginx e enviar `/api` à API .NET; **não executar `ng serve` em produção**.
- Teste final: URL profunda (`/projects/42`), 404 da API, cache do index, login/CSRF, refresh de página, HTTPS e cabeçalhos.

Fontes: https://angular.dev/guide/http/setup ; https://angular.dev/guide/http/interceptors ; https://angular.dev/best-practices/security
