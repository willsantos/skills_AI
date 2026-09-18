# Considerações técnicas condicionais

Aplicar apenas as seções relacionadas à demanda. Não adicionar complexidade preventiva sem evidência no contexto.

## Testes

Incluir testes pertinentes no escopo, na estimativa e nos critérios da Task principal.

Criar Task independente somente para trabalho relevante e separável, como:

- suíte E2E ampla;
- testes de carga ou resiliência;
- testes de contrato entre sistemas;
- infraestrutura de testes;
- automação de homologação complexa.

## Persistência e migrations

Avaliar separação quando houver:

- deploy em etapas;
- compatibilidade temporária entre versões;
- transformação relevante de dados;
- grande volume de registros;
- risco operacional;
- dependência entre releases ou equipes.

Quando aplicável, registrar compatibilidade, impacto sobre dados existentes, desempenho, ordem de deploy e estratégia de rollback.

## APIs e contratos

Identificar:

- contrato afetado;
- consumidores conhecidos;
- compatibilidade;
- validações e erros;
- necessidade de versionamento;
- possíveis breaking changes.

Nunca assumir que uma quebra de compatibilidade é aceitável. Os critérios devem representar o comportamento externo relevante.

## Mensageria

Considerar:

- produtor e consumidor;
- contrato da mensagem;
- idempotência;
- retry;
- dead-letter ou tratamento equivalente;
- correlação;
- tratamento de falhas;
- observabilidade.

Não criar automaticamente uma Task para cada aspecto. Separar somente quando houver independência ou risco suficiente.

## Observabilidade

Para fluxos críticos, assíncronos ou distribuídos, avaliar logs estruturados, métricas, tracing, correlação, identificação de falhas e alertas.

Incluir observabilidade quando necessária para operar a funcionalidade com segurança. Não acrescentá-la artificialmente a Tasks triviais.

## Segurança

Avaliar autenticação, autorização, permissões, secrets, validação de entrada, dados sensíveis, exposição de informações e superfície de ataque.

Impactos relevantes devem aparecer explicitamente no escopo ou nos critérios de aceite.

## Rollout e compatibilidade

Separar trabalho quando versões antigas e novas precisarem coexistir ou quando a mudança exigir ativação gradual. Registrar a ordem de entrega e os comportamentos que devem permanecer compatíveis.
