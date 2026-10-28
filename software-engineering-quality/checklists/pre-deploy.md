# Gate pré-deploy para alterações sensíveis

- [ ] Migrações exercitadas em ambiente equivalente e compatíveis com versões em coexistência.
- [ ] Backups e recuperação avaliados conforme criticidade.
- [ ] Dados críticos protegidos por constraint/transação/controle de concorrência.
- [ ] Reenvio de webhooks/jobs/requisições não duplica efeitos importantes.
- [ ] Autorização e escopo multi-tenant foram verificados, inclusive acesso cruzado.
- [ ] Segredos estão fora do build frontend e fora de logs/artefatos.
- [ ] Retries, timeouts, DLQ/outbox/reconciliação foram configurados quando aplicáveis.
- [ ] Traces, logs, métricas e alertas permitem diagnosticar falhas relevantes.
- [ ] Testes de integração críticos executados e resultado documentado.
- [ ] Existe procedimento de roll-forward/mitigação e responsável para incidentes.

**Bloqueadores típicos:** vazamento de dados entre tenants; pagamento duplicado; migração que elimina dados sem plano; segredos expostos; quebra de invariantes testada e reproduzida.

Para mudanças de baixo risco, registrar N/A em itens não pertinentes e evitar processo burocrático.
