# Concorrência e consistência transacional

## Identifique a invariante

Condições de corrida existem quando a correção depende de operações concorrentes sobre estado compartilhado. Exemplos: estoque >= 0, saldo >= 0, um único ocupante por vaga, limite de participantes, transições de estado válidas.

**Não confundir:** `CHECK(stock >= 0)` impede estoque negativo, mas não assegura sozinho que apenas uma de duas vendas baseadas na mesma leitura será confirmada. Proteja decisão + mutação conjuntamente.

## Estratégias em ordem de simplicidade

1. **Constraint e índice único:** o banco rejeita estados indevidos, inclusive quando múltiplos caminhos de escrita existirem. Use `CHECK`, `UNIQUE`, FKs e exclusões quando pertinentes. Constraint não executa a regra inteira.
2. **UPDATE condicional atômico:** quando a condição cabe no `WHERE`, faça a alteração no banco e verifique `RETURNING` ou quantidade de linhas afetadas.
3. **Controle otimista:** compare versão/etag no `WHERE` e avance a versão na mesma operação; rejeite ou refaça com estratégia explícita. EF Core com token configurado pode cuidar disso via `SaveChanges`.
4. **Lock de linha:** `SELECT ... FOR UPDATE` em transação para regras com múltiplas leituras/escritas; mantenha transação curta, ordem estável de locks e tratamento de deadlock.
5. **Isolamento mais forte:** `SERIALIZABLE` quando uma invariante abrange predicados/múltiplas linhas e não se resolve por outra via; retry da **transação inteira** em erro de serialização, com limite e backoff.
6. **Serialização via fila/coordenador:** quando realmente exigir ordenação entre processos, absorção de carga ou sequenciamento complexo. Ainda mantenha integridade no banco.

### Exemplo PostgreSQL

```sql
ALTER TABLE products ADD CONSTRAINT ck_products_stock_nonnegative CHECK (stock >= 0);

UPDATE products
SET stock = stock - :quantity
WHERE id = :id AND stock >= :quantity
RETURNING id, stock;
```

Sem linha retornada, diferenciar inexistência, falta de estoque ou conflito conforme contrato HTTP; não assumir sucesso. Em `READ COMMITTED`, PostgreSQL reavalia a condição de uma atualização após aguardar transação concorrente na linha.

### Mais de uma alteração

```sql
BEGIN;
-- reserve produto com UPDATE condicional, verifique resultado
-- insira pedido e itens
-- crie evento outbox se necessário
COMMIT;
```

Se qualquer passo falhar, executar `ROLLBACK`. Nunca chamar API externa enquanto segura locks por longo período. Uma transação só dá atomicidade no banco em que ela ocorre, não em e-mail, gateway ou fila remota.

### Anomalias que precisam de atenção

- **Lost update:** dois processos sobrescrevem o valor lido; use update relativo/versão.
- **Write skew:** transações editam linhas diferentes após leitura de um conjunto; lock na linha correta, constraint apropriada ou `SERIALIZABLE`.
- **Deadlock:** locks em ordem diferente; bancos abortam uma transação, que precisa ser tratada.
- **Lock timeout e starvation:** transações longas bloqueiam progresso.
- **Transição indevida:** `UPDATE ... WHERE status = 'pending'` pode proteger fluxo de estado; transições mais complexas exigem validação adicional.

### Teste que demonstra segurança

- Criar 1 unidade; liberar duas requisições concorrentes por barrier; aguardar ambas.
- Verificar exatamente uma operação bem-sucedida e estoque 0; repetir para reduzir flakiness.
- Em múltiplas linhas, forçar interleaving capaz de revelar anomalia; verificar invariantes finais.
- Usar PostgreSQL real e conexões independentes. Mock ou banco InMemory não reproduz locks e isolamento.

### Evitar

- `lock`/mutex no processo para proteger banco usado por múltiplas instâncias.
- `SELECT` seguido de `UPDATE` fora de transação e sem proteção.
- Check separado `SELECT EXISTS` antes de `INSERT` sem unique.
- Aumentar nível de isolamento indiscriminadamente, sem entender as consequências para throughput e retry.

Fonte de referência: https://www.postgresql.org/docs/current/transaction-iso.html e https://www.postgresql.org/docs/current/explicit-locking.html
