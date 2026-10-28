# Observabilidade útil, sem vazamento de dados

## Objetivo

Permitir responder: o que falhou, para quem, com qual operação, em que componente, com qual estado e como recuperar? Não confundir log abundante com capacidade de diagnosticar.

## Instrumentação mínima

- **Logs estruturados:** evento, operation name, request/correlation/trace ID, resultado, duração, identificadores opacos de recurso/tenant quando autorizados e úteis. Nunca logar token, segredo, senha, payload sensível, prompts privados completos por padrão.
- **Métricas:** taxa de erros por operação, latência p50/p95/p99 quando houver volume, deadlocks, conflito de versão, retries, `outbox_pending`, DLQ, tempo de job e saturação do pool.
- **Traces:** propagar trace context entre HTTP, banco, fila e integração; spans representam fronteiras úteis, evitando registrar SQL parametrizado com valores sensíveis.
- **Alertas:** ligados a sintoma que precisa de ação, com limiar e runbook claro. Ex.: fila de outbox não diminui, webhooks com erro persistente, 5xx anormal, aumento súbito de 403/401.

## Instrumentação ao implementar

1. Nomear operações de domínio (`CreateOrder`, `ConfirmPayment`).
2. Registrar erros em ponto único da borda; evitar log duplicado a cada camada.
3. Diferenciar erro esperado de negócio de erro operacional.
4. Correlacionar retries e evento original; preservar privacidade por hashing/redação quando necessário.
5. Instrumentar transições de estado sensíveis sem armazenar dados excessivos.

## Verificação

- Erros de autorização não revelam se objeto de terceiro existe, quando o contrato exige ocultação.
- Logs não possuem segredos nem dados pessoais desnecessários.
- Um webhook duplicado pode ser rastreado sem expor seu payload integral.
- Uma DLQ/outbox atrasada gera sinal operacional observável.
- A instrumentação não altera comportamento transacional nem aumenta desproporcionalmente a latência.

Fonte: https://opentelemetry.io/docs/concepts/observability-primer/
