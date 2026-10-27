# Padrões Angular 22

## Organização

Feature-first, código próximo do uso. O guia Angular desencoraja `components/`, `services/` e `directives/` globais que misturam domínios. Serviços compartilhados somente quando houver uso real em mais de uma feature.

## Rotas lazy (exemplo)

```ts
import type { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: 'projects',
    loadComponent: () =>
      import('./features/projects/pages/projects-page').then(m => m.ProjectsPage),
  },
];
```

O arquivo importado deve exportar `ProjectsPage`; adapte paths às convenções de nomes e à versão real. Autorização é executada no ASP.NET, não pela rota.

## Estado e fluxo

- `signal()` para estado local síncrono; `computed()` para valores derivados, sem watchers/efeitos desnecessários.
- `HttpClient` retorna Observables: use `async` pipe ou interop apropriada, cancelando subscriptions quando necessário.
- `inject()` para dependências; providers somente no escopo necessário. Não construir `BaseComponent` ou service genérico por antecipação.
- Formulários devem apresentar erros acessíveis, estados pending/erro/vazio e validações de UX; backend mantém invariantes.
- Preferir imports explícitos, templates acessíveis e testes co-localizados.

Fontes: https://angular.dev/style-guide ; https://angular.dev/guide/routing/define-routes ; https://angular.dev/reference/releases
