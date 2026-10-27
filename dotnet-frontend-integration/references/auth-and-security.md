# Autenticação, CSRF, CORS e autorização

## Modelo preferido de SaaS same-origin

- `/` serve SPA estática e `/api` encaminha para ASP.NET Core na **mesma origem** HTTPS.
- Sessão por cookie **HttpOnly, Secure** e atributo `SameSite` conforme jornada de login/SSO. O navegador envia cookie automaticamente dentro das regras de política.
- Para operações de mutação por cookie, estabelecer **CSRF efetivo e verificado** no backend; não supor que `SameSite` ou CORS resolvam tudo. API JSON pode precisar proteção deliberada mesmo que mecanismos automáticos cubram formulários. Testar chamadas maliciosas cross-site.
- Em Angular, `HttpClient` sabe ler `XSRF-TOKEN` e enviar `X-XSRF-TOKEN` em mutações same-origin. O servidor .NET deve emitir/validar token compatível; habilitar mecanismo adequado em operações JSON/cookies.
- Em Vue/fetch, implementar transporte do token no cabeçalho quando o backend exigir. Nunca copiar sessão para storage web para 'resolver' autenticação.

## Se múltiplas origens

- Precisar de CORS **somente** quando browser chama origem distinta. Lista exata de domínios autorizados. Política de credenciais explícita e testes de preflight.
- Explicitar `SameSite=None; Secure` apenas quando necessário e avaliar riscos extras.
- CORS é política de leitura no browser; não é autorização de API e não substitui por si só todas as defesas CSRF.

## Autorização

- Backend valida identidade, roles e **ownership do recurso** a cada operação protegida, incluindo tenant; filtros UI não protegem dados.
- Testes: não autenticado, papel errado, objeto de outro usuário/tenant, token expirado, alteração de cookie e replay de requisição de escrita.
- Proteção XSS: escaping padrão, evitar HTML cru/injeção, CSP conforme recursos usados; frontend com XSS consegue agir em nome da sessão, mesmo com cookie HttpOnly.

Referências:
- https://learn.microsoft.com/en-us/aspnet/core/security/anti-request-forgery?view=aspnetcore-10.0
- https://learn.microsoft.com/en-us/aspnet/core/security/cors?view=aspnetcore-10.0
- https://angular.dev/best-practices/security
