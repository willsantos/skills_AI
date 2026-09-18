# Exemplos de saída

Estes exemplos demonstram forma e hierarquia. Não reutilizar detalhes técnicos nem estimativas sem evidência na demanda real.

## Conteúdo

- Task simples
- Task consolidada com relacionadas
- Bug

## Task simples

````markdown
## Task 1 — Persistir o status de processamento da proposta

**Objetivo**

Permitir que o sistema mantenha o estado atual do processamento de uma proposta para consulta e retomada do fluxo.

**Estimativa Inicial (horas):** 4h

**Escopo**

- adicionar persistência do status de processamento;
- permitir a atualização do status durante o fluxo;
- manter compatibilidade com propostas existentes;
- adicionar testes automatizados para os estados suportados.

**Critérios de aceite**

```gherkin
Cenário: Persistir o status inicial
  Dado que uma proposta iniciou seu processamento
  Quando o estado do processamento for persistido
  Então a proposta deve possuir um status registrado

Cenário: Atualizar o status
  Dado que uma proposta possui um status registrado
  Quando o processamento avançar para uma nova etapa
  Então o novo status deve substituir o anterior
```
````

## Task consolidada com relacionadas

````markdown
## Task 1 — Implementar o processamento assíncrono de propostas

**Objetivo**

Permitir que propostas válidas sejam processadas de forma assíncrona após sua criação.

**Estimativa Inicial (horas):** 8h

**Escopo**

- publicar solicitações de processamento;
- consumir solicitações pendentes;
- tratar solicitações inválidas;
- disponibilizar identificação operacional de falhas;
- adicionar testes automatizados do fluxo.

**Critérios de aceite**

```gherkin
Cenário: Processar uma proposta de forma assíncrona
  Dado que uma proposta válida foi criada
  Quando a solicitação de processamento for publicada
  Então o fluxo assíncrono deve iniciar o processamento correspondente
```

> Esta Task precisa ser decomposta nas Tasks relacionadas abaixo.

---

### Task 1.1 — Publicar a solicitação de processamento

**Relacionada a:** Task 1 — Implementar o processamento assíncrono de propostas

**Objetivo**

Publicar uma solicitação após a criação válida de uma proposta.

**Estimativa Inicial (horas):** 3h

**Escopo**

- publicar a solicitação após a criação da proposta;
- incluir os dados necessários para identificá-la;
- impedir a publicação quando a criação falhar;
- adicionar testes automatizados dos cenários de sucesso e falha.

**Critérios de aceite**

```gherkin
Cenário: Publicar após criação bem-sucedida
  Dado que uma proposta foi criada com sucesso
  Quando a criação for concluída
  Então uma solicitação de processamento deve ser publicada

Cenário: Não publicar após falha
  Dado que a criação da proposta não foi concluída
  Quando a operação for encerrada
  Então nenhuma solicitação de processamento deve ser publicada
```

---

### Task 1.2 — Consumir a solicitação de processamento

**Relacionada a:** Task 1 — Implementar o processamento assíncrono de propostas

**Objetivo**

Iniciar o processamento da proposta correspondente a uma solicitação válida.

**Estimativa Inicial (horas):** 5h

**Escopo**

- consumir solicitações recebidas;
- identificar a proposta correspondente;
- iniciar seu processamento;
- rejeitar solicitações inválidas de forma identificável;
- adicionar testes automatizados dos cenários de sucesso e falha.

**Critérios de aceite**

```gherkin
Cenário: Consumir uma solicitação válida
  Dado que existe uma solicitação válida de processamento
  Quando ela for consumida
  Então o processamento da proposta correspondente deve ser iniciado

Cenário: Rejeitar uma solicitação inválida
  Dado que a solicitação não contém as informações necessárias
  Quando ela for consumida
  Então o processamento não deve ser iniciado
  E a falha deve ser identificável operacionalmente
```
````

## Bug

````markdown
## Task 1 — Corrigir duplicidade no processamento da proposta

**Objetivo**

Garantir que uma mesma solicitação produza apenas um processamento efetivo, inclusive quando for recebida novamente.

**Contexto**

O comportamento atual permite o processamento duplicado em reentregas da mesma solicitação. A causa técnica ainda não foi confirmada.

**Estimativa Inicial (horas):** 4h–8h

**Escopo**

- reproduzir o cenário de duplicidade;
- identificar a causa antes de implementar a correção;
- impedir efeitos duplicados para a mesma solicitação;
- preservar o processamento de solicitações distintas;
- adicionar testes automatizados de correção e regressão.

**Critérios de aceite**

```gherkin
Cenário: Reprocessar a mesma solicitação
  Dado que uma solicitação já foi processada com sucesso
  Quando a mesma solicitação for recebida novamente
  Então nenhum efeito adicional deve ser produzido

Cenário: Processar solicitações distintas
  Dado que existem duas solicitações válidas e distintas
  Quando ambas forem recebidas
  Então cada solicitação deve produzir seu próprio processamento
```
````
