# Casos de avaliação Vue

1. Criar tela de projetos com paginação: feature coesa, router lazy, sem store Pinia desnecessária.
2. Contrato de API alterado: cliente regenerado de OpenAPI, sem ajuste manual de `generated/`.
3. Erro `401` e `403`: UX correta sem declarar autorização no browser.
4. Sessão por cookie: mutações protegidas por CSRF **validado pelo backend**.
5. Componente usa `any` e interface duplicada: deve ser rejeitado na revisão.
6. Build de produção: dist estático com `/api` relativo, sem serviço Node/Vite em runtime.
7. `VITE_API_SECRET` sugerido: recusar segredo no bundle público.
