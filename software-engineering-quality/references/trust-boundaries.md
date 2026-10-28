# Fronteiras de confiança, autorização, segredos e IA

## Modelo de ameaças mínimo

Definir entradas que um atacante controla: navegador, aplicativo móvel, URL, cookies, headers, arquivos, webhooks, mensagens de fila, payload de provedor e texto gerado por LLM. A autenticação de uma conexão não confere automaticamente autorização aos objetos acessados.

## Regras

1. **Dados de negócio:** o cliente pode informar produto/quantidade/opções; preço, imposto, desconto aplicável, saldo e permissões precisam ser determinados/validados pelo backend.
2. **Autenticação:** identidade deve vir de mecanismo confiável, com tokens/sessões validados; nunca aceitar livremente `userId`, `isAdmin`, `tenantId` como autoridade.
3. **Autorização por objeto e ação:** cada leitura/edição/exclusão/exportação deve conferir propriedade/associação/permissão. Inclua tenant no filtro e aplique política também em endpoints batch/background.
4. **Segredos:** chaves privadas e tokens administrativos apenas em backend/secret manager; nunca embedar segredo em bundle JS, log, prompt ou respostas. Chaves públicas são diferentes de secrets, mas ainda exigem políticas.
5. **Validação e serialização:** limite tamanho, tipo, formato e intervalo; queries parametrizadas; upload restrito; proteção contra CSRF quando sessões por cookie e operação mutável forem usadas; rate limit conforme abuso.
6. **Integrações e webhooks:** validar assinatura/autenticidade, timestamp, replay e mapeamento de recursos; retornos externos não concedem privilégios.
7. **LLM:** prompt injection não pode alterar políticas. Restrinja ferramentas por escopo e credenciais do usuário, valide parâmetros com schemas, obtenha confirmação para ações sensíveis, evite expor segredos e dados de outros tenants ao modelo, trate saída como dados não confiáveis.

## RLS com PostgreSQL

Pode reduzir impacto de consultas esquecidas em cenários multi-tenant. Exemplo ilustrativo:

```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY projects_by_tenant ON projects
USING (tenant_id = current_setting('app.tenant_id')::uuid)
WITH CHECK (tenant_id = current_setting('app.tenant_id')::uuid);
```

**Pré-condições:** app define tenant a partir de identidade autenticada e dentro de transação usando `SET LOCAL`/`set_config(..., true)` em conexão adequada; role do aplicativo sem `BYPASSRLS` e sem privilégios de owner que ignorem RLS (avaliar `FORCE ROW LEVEL SECURITY`); políticas para operações necessárias; evitar vazamento entre conexões do pool e testes que troquem tenant. RLS não é proteção completa quando o app permite SQL injection ou confia em tenant arbitrário do cliente. Sempre validar autorização também no backend.

## Testes de segurança críticos

- Usuário A tenta acessar, atualizar e excluir recurso de B (BOLA/IDOR).
- Usuário de tenant A tenta filtrar/exportar dados de B; testar com conexões reaproveitadas.
- Alteração de preço, desconto, papel/tenant e quantidade no payload.
- Webhook sem assinatura, com assinatura inválida, fora da tolerância e duplicado.
- Ferramenta do agente recebe instrução maliciosa no documento recuperado e tenta executar ação não autorizada.
- Input inválido, limites de tamanho e condições de race entre autenticação e mutação.

Fontes: https://owasp.org/API-Security/editions/2023/en/0xa1-broken-object-level-authorization/ e https://www.postgresql.org/docs/current/ddl-rowsecurity.html
