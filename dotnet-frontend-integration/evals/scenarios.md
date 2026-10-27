# Cenários de validação da integração

1. SPA same-origin com sessão: login válido, cookie HttpOnly Secure, mutação com CSRF, 401 e 403.
2. POST sem autorização cross-site: rejeitar; demonstrar defesa no backend, não só headers do frontend.
3. API troca `price` por `amount`: CI acusa drift do OpenAPI e regenera SDK; não patch manual gerado.
4. Usuário A tenta ler pedido de B: backend impede por ownership/tenant.
5. Caddy SPA: `/api/inexistente` retorna 404 API, `/orders/123` entrega HTML estático com fallback.
6. Token LLM em SSE: desconexão do cliente cancela servidor sem vazar recursos.
7. Worker de arquivo grande: não manter requisição longa nem deixar job sem autenticação.
8. Deploy sem execução de comando: agente não afirma builds ou testes passaram.
