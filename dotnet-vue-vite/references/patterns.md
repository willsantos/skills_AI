# Vue: convenções por feature

## Padrão mínimo

- `src/features/orders/pages/OrdersPage.vue`, `components/OrderRow.vue`, `composables/useOrders.ts`.
- `src/api/generated` é exclusivo do gerador. `src/features/orders/api/ordersApi.ts` pode adaptar SDK para UI, sem reproduzir regras de negócio.
- `src/shared/ui/` só recebe componente usado em **duas ou mais features** de fato; evitar catálogo preventivo.
- `<script setup lang="ts">`, props/emits tipados, `computed` para derivados. Evitar watchers redundantes e `any`.
- Formulários têm estados `idle/submitting/success/error`, botões desabilitados com razão, erros associados a campos e foco acessível.
- Priorizar `ref` local; Pinia para sessão, preferências ou contexto compartilhado, não como store universal de API.
- Paginação/busca: parâmetros explícitos, debounce onde necessário, cancelamento para evitar respostas obsoletas.
- Renderização de HTML não confiável: evitar `v-html` salvo sanitização cuidadosamente verificada.

## Exemplo de rota com lazy loading

```ts
import { createRouter, createWebHistory } from 'vue-router'

export const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/projects',
      component: () => import('../features/projects/pages/ProjectsPage.vue'),
    },
  ],
})
```

Backend protege recursos mesmo quando guards de navegação ocultam telas.

Referências: https://vuejs.org/guide/typescript/overview ; https://router.vuejs.org/guide/advanced/lazy-loading
