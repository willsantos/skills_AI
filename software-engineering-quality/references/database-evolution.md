# Evolução segura de schema e deploys

## Premissa

Em produção, versão antiga e nova da aplicação podem coexistir, mesmo em VPS Linux durante reinícios/rollouts. Planejar mudanças para essa janela, não apenas para schema final.

## Estratégia expand/contract

1. **Expand:** adicionar coluna nullable, tabela/índice ou nova representação sem quebrar versão antiga.
2. **Adotar:** publicar código capaz de ler ambos/usar novo campo; se necessário dual-write transitoriamente com testes.
3. **Backfill:** popular dados antigos em lotes observáveis, reentrantes e com interrupção segura.
4. **Validar:** conferir cardinalidade, unicidade, relacionamentos, índices e consistência de leitura.
5. **Contract:** somente após todas as instâncias migrarem, remover campo/caminho legado e aplicar NOT NULL/constraints definitivas.

## Considerações PostgreSQL

- Índices grandes podem exigir `CREATE INDEX CONCURRENTLY`; não rodar dentro de transaction block e considerar falhas que deixam índice inválido.
- Constraints podem exigir `NOT VALID` e depois `VALIDATE CONSTRAINT` para reduzir impacto em tabelas grandes, conforme tipo suportado.
- Alterações de tipo, defaults e reescritas de tabela podem bloquear operação; conferir versão e plano de execução na documentação.
- Usar migrations versionadas; evitar `EnsureCreated` como substituto de migrations em produção.
- Backups precisam ser testados com restauração. Rollback de código pode ser insuficiente para desfazer mudança de dados.

## Checklist de revisão

- Aplicação antiga funciona no novo esquema pelo período de transição?
- Testes aplicam as mesmas migrations que produção?
- O backfill cabe no volume e lock budget disponível?
- Existe plano de recuperação/reconciliação se falhar a meio caminho?
- Índices suportam novas queries e constraints evitam duplicação?
- Métricas, alertas, tráfego e logs permitem acompanhar a publicação?

Evitar migração destrutiva em um único deploy quando existe coexistência de versões. Documentar exceções para sistema de instância única com janela de manutenção real.

Fonte: https://www.postgresql.org/docs/current/sql-createindex.html
