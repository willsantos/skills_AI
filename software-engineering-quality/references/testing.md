# Estratégia de testes baseada em risco

## Seleção de níveis

- **Unitário:** regras puras, algoritmos, cálculos complexos, tabelas de decisão, entradas-limite. Rápidos e numerosos quando fizer sentido.
- **Integração:** endpoint HTTP + middleware + negócio + PostgreSQL real; verificar estado persistido, constraints, transações, idempotência, autorização. Geralmente maior valor para fluxos de backend.
- **Contrato:** integração com serviços externos por schema ou stub fideligno; assumir incerteza de rede e mudanças de contrato.
- **E2E:** jornadas essenciais com browser, autenticação realista e UI. Poucos, determinísticos e voltados a problemas que só existem na interface.

**Atenção:** `WebApplicationFactory` sem navegador não exercita JavaScript do frontend. Usar testes próprios de UI ou Playwright para isso.

## Matriz mínima por risco

| Tipo de função | Testes necessários |
| --- | --- |
| CRUD público simples | Sucesso, validação, persistência |
| Dados privados | Sucesso autenticado, não autenticado, acesso cruzado A/B, mudança de tenant |
| Estoque/cotas | Sucesso, insuficiência, 2+ transações concorrentes, rollback |
| Pagamento/webhook | Evento válido, assinatura inválida, duplicata sequencial/concorrente, fora de ordem, crash parcial |
| Integração externa | timeout, 429/5xx, retry seguro, irreversibilidade, indisponibilidade |
| Migração | Nova aplicação + esquema alterado, compatibilidade, índices/constraints e caminho de rollback |

## Isolamento de teste

- Usar banco real para efeitos SQL; InMemory SQLite não reproduz as mesmas constraints, locks ou semântica do PostgreSQL.
- Isolar dados entre testes: DB/schema único por suíte ou transações apropriadas; testes concorrentes exigem **conexões distintas**, evitando que isolamento do fixture mascare disputa.
- Aplicar migrations de produção no banco de teste; não criar schema paralelo de maneira que ignore constraints.
- Evitar sleep arbitrário como sincronização. Usar barreiras, latches e coordenar transações quando for necessário reproduzir uma janela específica.
- Controlar tempo, randomização e respostas de APIs externas; falhas de teste devem indicar defeito, não flakiness.
- Não mockar o componente que contém exatamente a propriedade a ser validada.

## Exemplos de invariantes

```text
Dado estoque=1, quando duas reservas concorrentes ocorrem,
então sucesso=1, falha=1, estoque final=0.

Dado webhook E, quando E chega 3 vezes,
então pagamento e liberação são registrados somente uma vez.

Dado usuário A e pedido de B, quando A tenta GET/PUT/DELETE,
então A não visualiza nem modifica o objeto.
```

Não há obrigação de usar uma sintaxe Gherkin literal: o importante é definir estado inicial, gatilho e estado observável.

## Reporting de agente

Informar `comando`, `quantidade de testes` se conhecida, `passou/falhou/não executado`, ressalvas de ambiente e cobertura dos riscos. Nunca inventar execução. Se não houver Docker ou runtime, produzir testes e marcar claramente como não executados.
