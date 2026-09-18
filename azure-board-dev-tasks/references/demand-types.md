# Tipos de demanda

## Feature ou melhoria

Decompor pelo resultado técnico necessário, não automaticamente por camada. Considerar somente quando aplicável:

- domínio;
- API e contratos;
- persistência;
- mensageria;
- frontend;
- integrações;
- infraestrutura;
- segurança;
- observabilidade;
- migration e rollout.

Separar uma parte quando ela for significativa, independente e verificável.

## Bug

Registrar, quando conhecido:

- comportamento atual;
- comportamento esperado;
- cenário de reprodução;
- causa confirmada;
- escopo da correção;
- risco de regressão.

Nunca apresentar hipótese de causa como diagnóstico. Se a causa ainda for incerta e essa incerteza impedir a implementação, criar uma investigação separada; caso contrário, manter investigação e correção na mesma Task.

Os critérios devem cobrir o cenário defeituoso e o comportamento esperado após a correção. Adicionar regressão adjacente quando houver risco real.

## Débito técnico

Explicitar:

- problema atual;
- consequência técnica;
- resultado esperado;
- limites da alteração;
- comportamento que deve permanecer inalterado.

Evitar títulos vagos como `Refatorar serviço`. Preferir um resultado, como `Separar regras de cálculo do fluxo HTTP` quando esses elementos estiverem confirmados no contexto.

Critérios podem validar arquitetura ou qualidade técnica, mas precisam ser verificáveis. Exemplos: uma dependência deixa de existir, um contrato público permanece inalterado ou um módulo passa a ser testável sem infraestrutura externa.

## Spike ou investigação

Usar quando não houver informação suficiente para determinar a implementação. Formular uma pergunta técnica clara e exigir uma saída concreta:

- decisão técnica;
- comparação com trade-offs;
- ADR;
- recomendação fundamentada;
- prova de conceito;
- limitações identificadas.

Evitar `Estudar tecnologia X`. Preferir `Avaliar estratégia de idempotência para o processamento de propostas`.

Exemplo de critério:

```gherkin
Cenário: Concluir a avaliação das alternativas
  Dado que existem estratégias viáveis para resolver a questão técnica
  Quando a investigação for concluída
  Então as alternativas avaliadas e seus trade-offs devem estar documentados
  E deve existir uma recomendação técnica fundamentada
```
