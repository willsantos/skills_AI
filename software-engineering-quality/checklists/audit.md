# Checklist para auditoria e revisão de PR

1. **Escopo:** diff, paths relacionados, contratos, migrations, testes e instruções do projeto.
2. **Risco:** classificar importância e probabilidade conforme `references/risk-triage.md`.
3. **Segurança:** autenticação confiável? Autorização por recurso e tenant? Campos privilegiados ignorados? Segredos expostos? Query parametrizada? LLM/tool permission?
4. **Concorrência:** read-modify-write sem condição/lock? Check-then-insert sem unique? Múltiplas mutações sem transação? deadlock e retries?
5. **Idempotência:** retry de POST/webhook/job? Marca evento em transação diferente do efeito? Sem unicidade? Dois eventos distintos com mesmo fato de negócio?
6. **Integrações:** Timeout e cancelamento? retry seletivo? side effect externo fora de transação? outbox/reconciliação quando necessário?
7. **Manutenção:** feature localizável, regras coesas, dependências corretas, abstrações justificadas?
8. **Testes:** invariantes cobertas por testes que realmente exercitam mecanismo (PostgreSQL e multi-conexão quando necessário)?
9. **Migrations:** compatibilidade entre versões, lock/índice, backfill, recuperação e observabilidade?
10. **Evidência:** cada apontamento tem localização precisa, cenário, gravidade justificada e correção objetiva?

## Formato de saída sugerido

```text
[P1] Título curto — src/Modules/Orders/CreateOrder/Handler.cs:42
Evidência: leitura do estoque e escrita sem condição/transação; duas chamadas podem aprovar a última unidade.
Impacto: duas vendas concorrentes para 1 unidade.
Correção mínima: UPDATE condicional e verificação das linhas afetadas.
Teste: integrar duas requisições simultâneas, estoque inicial 1.
```

Separar **achado confirmado**, **risco provável a confirmar** e **sugestão de melhoria**. Não preencher lista com hipóteses sem base. Se não existem achados, explicar o escopo e limitações.
