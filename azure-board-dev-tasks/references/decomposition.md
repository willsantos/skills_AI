# Decomposição e granularidade

## Identificar o nível do trabalho

Uma demanda que expressa valor funcional amplo pode pertencer ao nível de User Story, Product Backlog Item, Feature, Issue ou Requirement, conforme o processo do Azure Boards.

Quando a demanda estiver acima do nível de uma Task:

1. informar na Task consolidada que o item exige decomposição;
2. preservar o objetivo original como referência;
3. criar Tasks relacionadas executáveis imediatamente abaixo dele.

Não transformar uma feature inteira em uma única unidade de execução apenas para evitar decomposição.

## Sequência de análise

Responder internamente:

1. Qual resultado final precisa existir?
2. Quais componentes realmente precisam mudar?
3. Quais mudanças produzem resultados técnicos independentes?
4. Quais mudanças podem ser validadas isoladamente?
5. Existe ordem obrigatória entre elas?
6. Há risco de migration, deploy ou compatibilidade?
7. Existe contrato entre componentes?
8. Alguma decisão ainda exige investigação?
9. A estimativa revela que o item está grande demais?
10. Algum item ficou pequeno demais e deve ser incorporado a outro?

Gerar somente as Tasks necessárias após essa análise.

## Critérios para decompor

Decompor quando houver um ou mais destes sinais:

- vários resultados técnicos independentes;
- implementação, revisão e validação que excedam razoavelmente um dia de uma pessoa;
- componentes com ciclos de entrega ou responsáveis distintos;
- migration ou rollout em etapas;
- contrato que precise preceder produtor ou consumidor;
- investigação necessária antes da implementação;
- risco operacional que justifique entrega isolada;
- parte do trabalho capaz de gerar valor técnico e ser validada separadamente.

Não decompor automaticamente por camada. Evitar árvores como `criar repository`, `criar service` e `criar controller` quando essas etapas formam uma única unidade de comportamento.

## Task consolidada

A Task consolidada descreve o resultado total, os limites comuns e os critérios de aceite de ponta a ponta. Ela não é esforço adicional às Tasks relacionadas.

As Tasks relacionadas devem:

- possuir um resultado técnico próprio;
- ser verificáveis isoladamente;
- indicar a Task consolidada em `Relacionada a`;
- conter sua própria estimativa e seus próprios critérios;
- aparecer em sequência logo após a Task consolidada.

## Dependências

Declarar dependência somente quando uma Task não puder ser implementada ou validada antes de outra.

Exemplo:

```markdown
**Dependências**

- Task 1.2 depende do contrato definido na Task 1.1.
```

Não declarar dependência por mera preferência de ordem. Se Tasks puderem ocorrer em paralelo, não criar relação artificial.
