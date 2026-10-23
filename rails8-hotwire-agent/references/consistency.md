# Concorrência, integridade e idempotência

Ler ao alterar invariantes concorrentes, unicidade, pagamentos, jobs ou publicação confiável. Adicionar apenas mecanismos necessários ao caso, não uma infraestrutura de eventos para todo CRUD.

## Escritas e integridade

- `validates uniqueness:` não impede corrida; criar índice único no banco, incluindo tenant quando domínio exigir. Tratar `ActiveRecord::RecordNotUnique` apenas para duplicidade reconhecida; não converter toda falha SQL em erro de validação.
- `update_all`, `insert_all`, `update_columns` e SQL manual não executam todas as validations/callbacks. Garantir escopo e constraints antes de usá-los; não confiar em callbacks de auditoria/enqueue nesses caminhos.
- Para edição concorrente, considerar `lock_version`: incluir versão original no formulário e strong parameters, tratar `ActiveRecord::StaleObjectError` e apresentar conflito sem sobrescrever silenciosamente. Não aceitar versão de outro registro/tenant.
- Para estoque/saldo, considerar atualização SQL condicional atômica ou `with_lock` em transação curta, com releitura e revalidação. SQLite e PostgreSQL têm modelos de concorrência diferentes; provar comportamento no banco real do projeto.
- Testar duas instâncias lendo versão igual, duas criações com mesma chave e tentativas de ultrapassar saldo/estoque. Não adicionar retry que repete efeito externo indiscriminadamente.
- Valores monetários precisam de moeda, faixa e política de escala/arredondamento. Alinhar domínio/entrada/coluna e testar valor persistido; `decimal(precision, scale)` não define sozinho uma regra de negócio.

## Commit e fila

1. Definir quais alterações precisam confirmar juntas. `save` tem transação própria, mas vários saves relacionados podem exigir transação explícita; usar exceções/retornos que provoquem rollback quando necessário.
2. Enqueue após commit evita job lendo dados não confirmados. Não elimina janela de falha entre commit e enfileiramento, especialmente com Solid Queue em outro banco.
3. Se entrega for obrigatória, persistir outbox e estado de negócio na mesma transação. Publicador com retry entrega pelo menos uma vez; consumidor deduplica na mesma transação do efeito local.
4. Testar queda antes/depois do commit e antes/depois da publicação. Monitorar atraso/erro e ter recuperação; não prometer exactly-once ponta a ponta.

## Efeitos externos e idempotência

- `return if generated?` não protege execução simultânea. Se efeito for apenas local, protegê-lo por transação/lock/constraint ou atualização condicional.
- Chave idempotente deve ter escopo tenant + operação + chave e unicidade persistida. Guardar hash do pedido, estado e resultado. Mesma chave com outro payload deve ser rejeitada.
- Cobrança remota: enviar chave estável suportada pelo gateway; timeout pode significar efeito concluído com resposta perdida. Reconciliar antes de repetir ou compensar.
- Definir expiração, execução em andamento, recuperação após crash, política de retry limitada e proteção de dados sensíveis.
- Não manter lock/transação de banco aberta enquanto chama rede; lock local não desfaz efeito remoto. Evitar usar flag de processamento como garantia sem recuperação de crash.

## Exemplo comprovado e limites

Sandbox em `testing-example.md` demonstra optimistic locking e job com atualização local condicional: duas execuções sequenciais não incrementam contador duas vezes. Não comprova corrida real de workers nem entrega Solid Queue, pagamentos, outbox ou banco PostgreSQL. Essas áreas exigem testes específicos no ambiente alvo.

## Fontes

- [Locking Active Record](https://guides.rubyonrails.org/active_record_querying.html#locking-records-for-update).
- [Transações e Active Job](https://guides.rubyonrails.org/active_job_basics.html#transactional-integrity-on-jobs).
- [Validações Active Record](https://guides.rubyonrails.org/active_record_validations.html).
- [Transactional Outbox](https://microservices.io/patterns/data/transactional-outbox.html).
