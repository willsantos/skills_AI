# Triagem de risco: aplicar controles proporcionais

## 1. Primeiro procure invariantes

- Quais valores ou estados jamais podem coexistir? Ex.: saldo < 0, dois donos exclusivos, pagamentos duplicados, pedido pago sem entrega.
- A regra depende de um recurso compartilhado? Existem mais de uma instância/processo, jobs ou webhooks escrevendo nas mesmas tabelas?
- Uma mensagem ou requisição pode ser repetida, atrasar ou chegar fora de ordem?
- O cliente pode manipular preço, identidade, tenant, escopo, permissões ou parâmetros da consulta?
- Existe sistema externo fora da transação? Há reprocessamento, rollback e reconciliação?
- Há dados privados, dinheiro, segredos, ações destrutivas ou disponibilidade essencial?

## 2. Classificar por impacto e probabilidade

| Impacto | Exemplo | Expectativa |
| --- | --- | --- |
| Baixo | Preferência visual, pesquisa pública simples | Validação e testes proporcionais |
| Médio | Atualização de perfil, comentários, filtros restritos | Autorização, persistência e testes dos principais erros |
| Alto | Estoque, cobrança, cotas, convites, alteração de acesso | Invariantes DB, tratamento de concorrência/replay, testes com banco real |
| Crítico | Movimentação financeira, identidade, dados regulados | Defesa em profundidade, reconciliação, auditoria e testes de falha sistemáticos |

A classe não dispensa controles básicos: autenticação/autorização continuam obrigatórias para recursos privados mesmo em tarefas pequenas.

## 3. Decisão guiada por sinais

- Contador ou saldo? UPDATE condicional, constraints, e verificação de linhas afetadas; transação para múltiplas mutações.
- Fluxo que pode ser repetido? Chave/evento único, atomicidade com efeito de negócio e transição de estado; verificar duplicatas diferentes do mesmo fato.
- Leitura/modificação de recurso privado? Resolver identidade no servidor e aplicar autorização por objeto e operação.
- Integração externa? Timeout, retry seletivo, idempotência, outbox ou reconciliação conforme criticidade.
- Regra pura complexa? Teste unitário; fluxo com EF/DB/middleware? Teste de integração; navegação crítica? E2E pontual.
- Migração em tabela crítica? Expand/contract, índices sem bloqueios desnecessários, rollback/roll-forward e observabilidade.

## 4. Evidência mínima

- Nomeie o risco e sua consequência.
- Mostre qual mecanismo o contém (ou por que não se aplica).
- Associe um teste ou estratégia de observação.
- Se houver risco residual, explicite e proponha um gatilho observável para aumentar a complexidade.

## Antipadrões

- Exigir fila para toda escrita; usar Redis como fonte de verdade sem justificativa.
- Especificar ‘exactly once’ para efeitos externos sem mecanismo de deduplicação.
- Criar repositório por entidade, mediator, DI ou classes fictícias só para demonstrar arquitetura.
- Marcar todos os itens como implementados sem executar os testes correspondentes.
