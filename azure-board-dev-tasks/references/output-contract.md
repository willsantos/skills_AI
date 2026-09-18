# Contrato de saída

## Conteúdo

- Formato obrigatório
- Task consolidada e Tasks relacionadas
- Estimativa inicial
- Critérios de aceite em Gherkin pt-BR
- Metadados

## Formato obrigatório

Entregar somente Markdown. Não anteceder as Tasks com explicações sobre o processo e não encerrar com recomendações genéricas.

Usar esta estrutura:

````markdown
## Task 1 — <Título>

**Objetivo**

<O que precisa passar a ser verdade após a implementação.>

**Contexto**

<Somente o contexto necessário. Omitir quando dispensável.>

**Estimativa Inicial (horas):** <valor, faixa ou indicação fundamentada de insuficiência>

**Escopo**

- <resultado ou alteração necessária>;
- <restrição relevante>;
- <testes automatizados pertinentes>.

**Critérios de aceite**

```gherkin
Cenário: <resultado observável>
  Dado <contexto inicial>
  Quando <ação ou condição>
  Então <resultado esperado>
```

**Fora de escopo**

- <limite necessário para evitar interpretação excessiva>.

**Dependências**

- <dependência real conhecida>.

**Observações técnicas**

- <decisão, padrão, restrição ou risco confirmado>.

**Work Item Type:** Task
**Parent:** <ID ou título conhecido>
**Area:** <área conhecida>
**Iteration:** <sprint conhecida>
**Tags:** <tags conhecidas>
````

Título, objetivo, estimativa, escopo e critérios de aceite são obrigatórios. As demais seções são condicionais.

## Task consolidada e Tasks relacionadas

Quando houver decomposição, usar:

```markdown
## Task 1 — <Objetivo consolidado>

<campos obrigatórios e seções relevantes>

> Esta Task precisa ser decomposta nas Tasks relacionadas abaixo.

---

### Task 1.1 — <Primeiro resultado executável>

**Relacionada a:** Task 1 — <Objetivo consolidado>

<campos obrigatórios e seções relevantes>

---

### Task 1.2 — <Segundo resultado executável>

**Relacionada a:** Task 1 — <Objetivo consolidado>

<campos obrigatórios e seções relevantes>
```

Não intercalar outros objetivos entre uma Task consolidada e suas Tasks relacionadas. Ordenar assim:

```text
Task 1
Task 1.1
Task 1.2
Task 2
Task 3
Task 3.1
```

## Estimativa inicial

Estimar esforço técnico, não prazo de calendário. Incluir implementação, testes automatizados, ajustes previsíveis e validação técnica. Não incluir branch, commit, PR ou cerimônias comuns.

Usar horas inteiras ou faixas compreensíveis, por exemplo:

- `2h`
- `4h`
- `6h`
- `8h`
- `12h`
- `4h–8h`

Evitar falsa precisão, como `3h17min`.

Quando faltar contexto essencial, manter o campo obrigatório e registrar:

```markdown
**Estimativa Inicial (horas):** A estimar — contexto técnico insuficiente
```

Usar faixa somente quando houver base para delimitar os extremos. Se a estimativa indicar esforço excessivo ou múltiplos resultados independentes, decompor a Task.

Na decomposição:

- a estimativa da Task consolidada representa o total;
- cada Task relacionada recebe sua própria estimativa;
- o total deve ser compatível com a soma das relacionadas;
- não somar novamente a Task consolidada ao calcular o esforço do conjunto.

## Critérios de aceite em Gherkin pt-BR

Usar `Cenário`, `Dado`, `Quando`, `Então`, `E` e `Mas`. Descrever comportamento observável, não a existência de classes, métodos ou arquivos.

Criar normalmente de um a quatro cenários por Task. Adicionar cenários de erro ou regressão apenas quando caracterizarem a conclusão.

Preferir:

```gherkin
Cenário: Impedir processamento de uma solicitação inválida
  Dado que a solicitação não contém os dados obrigatórios
  Quando o processamento for iniciado
  Então a solicitação não deve ser processada
  E a falha deve ser identificável operacionalmente
```

Evitar:

```gherkin
Cenário: Criar o serviço
  Dado que o desenvolvedor criou uma classe
  Quando adicionar um método
  Então o método deve existir
```

Não usar como critérios: `Código implementado`, `PR aprovado`, `Testes realizados` ou `Funcionando corretamente`.

## Metadados

Adicionar metadados somente quando forem conhecidos. Nunca inferir responsável, sprint, prioridade, Area Path, Iteration Path, tags organizacionais ou IDs.
