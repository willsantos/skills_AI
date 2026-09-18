---
name: azure-board-dev-tasks
description: Transformar demandas, bugs, melhorias, débitos técnicos e investigações de software em Tasks técnicas estruturadas para posterior inclusão no Azure Boards. Usar quando for preciso analisar ou decompor trabalho de desenvolvimento e entregar somente Markdown com objetivo, escopo, estimativa inicial em horas e critérios de aceite BDD/Gherkin em pt-BR. Não usar para criar ou alterar Work Items diretamente.
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
---

# Azure Boards Development Tasks

## Objetivo

Produzir uma especificação intermediária em Markdown que permita a outro desenvolvedor entender o que precisa mudar, qual resultado deve existir, como validá-lo e qual é a estimativa técnica inicial.

Não criar, alterar ou publicar Work Items. Não chamar APIs, CLIs ou conectores do Azure DevOps. Mesmo que exista integração disponível, limitar esta skill à geração do Markdown.

## Fluxo

1. Analisar a demanda e todo o contexto disponível.
2. Quando houver repositório ou documentação, localizar componentes, padrões, contratos, testes e implementações relacionadas antes de redigir as Tasks.
3. Identificar o nível do trabalho e o tipo de demanda.
4. Decidir se o trabalho cabe em uma Task executável ou se exige uma Task consolidada seguida de Tasks relacionadas.
5. Carregar apenas as referências aplicáveis indicadas abaixo.
6. Gerar as Tasks na ordem lógica de implementação.
7. Revisar títulos, escopo, estimativas, critérios, hipóteses e dependências.
8. Entregar somente o Markdown das Tasks, sem relato do processo de análise.

## Regras essenciais

- Descrever resultados técnicos concretos, não atividades genéricas.
- Preferir títulos curtos com verbo no infinitivo, como `Implementar`, `Adicionar`, `Migrar`, `Corrigir`, `Expor`, `Restringir` ou `Instrumentar`.
- Não criar Tasks isoladas para branch, commit, PR, revisão, execução comum de testes, deploy convencional ou atualização do board.
- Considerar testes parte da implementação, do escopo e da estimativa.
- Não inventar classes, tabelas, endpoints, eventos, filas, serviços, bibliotecas, IDs, responsáveis, sprints ou padrões internos.
- Marcar como hipótese qualquer informação não confirmada que seja necessária para estruturar o trabalho.
- Omitir seções opcionais vazias; nunca preencher campos apenas para completar o template.
- Preservar decisões locais de implementação quando a demanda não exige uma solução específica.

## Granularidade e hierarquia

Preferir Tasks que possam ser implementadas, revisadas e validadas por uma pessoa em aproximadamente um dia. Usar esse limite como heurística, não como regra mecânica.

Se a demanda for ampla demais:

- manter a Task consolidada primeiro;
- registrar que ela precisa ser decomposta;
- apresentar as Tasks relacionadas imediatamente abaixo, com numeração hierárquica (`Task 1.1`, `Task 1.2`);
- estimar a Task consolidada pelo esforço total e cada Task relacionada pelo próprio esforço;
- manter o total consolidado coerente com as estimativas relacionadas;
- explicitar apenas dependências reais; não serializar trabalho que pode ocorrer em paralelo.

Ler [references/decomposition.md](references/decomposition.md) sempre que houver mais de uma Task, dúvida sobre granularidade ou necessidade de hierarquia.

## Contrato de saída

Toda Task deve conter:

1. título orientado a resultado;
2. objetivo;
3. estimativa inicial em horas;
4. escopo;
5. critérios de aceite em BDD/Gherkin pt-BR.

Contexto, fora de escopo, dependências, observações técnicas e metadados aparecem apenas quando relevantes.

Ler [references/output-contract.md](references/output-contract.md) antes de gerar a resposta. Essa referência define o template obrigatório, a política de estimativas, a sintaxe dos critérios e a ordenação.

## Tipo de demanda

Ler [references/demand-types.md](references/demand-types.md) quando a solicitação envolver feature, melhoria, bug, débito técnico, spike ou investigação. Aplicar somente a seção correspondente.

## Impactos técnicos condicionais

Ler [references/technical-considerations.md](references/technical-considerations.md) quando houver API, contrato entre sistemas, persistência, migration, mensageria, integração, segurança, observabilidade, rollout ou testes técnicos independentes. Aplicar somente os tópicos presentes na demanda ou encontrados no contexto.

## Exemplos

Ler [references/examples.md](references/examples.md) somente quando for útil conferir a forma final, a hierarquia ou o tratamento de um bug. Não copiar nomes, estimativas ou requisitos dos exemplos para uma demanda real.

## Revisão final

Antes de responder, confirmar que:

- a saída contém apenas Markdown das Tasks;
- nenhum Work Item foi criado ou alterado;
- cada título expressa um resultado;
- cada Task possui um único objetivo principal;
- escopo e critérios são verificáveis e não contraditórios;
- todos os critérios estão em Gherkin pt-BR;
- toda Task possui estimativa inicial, incluindo Tasks consolidadas e relacionadas;
- testes estão considerados sem decomposição artificial;
- riscos de contrato, dados, segurança, observabilidade e rollout foram tratados quando aplicáveis;
- detalhes desconhecidos não foram apresentados como fatos;
- Tasks relacionadas aparecem imediatamente após a Task consolidada;
- nenhuma Task é trivial demais ou ampla demais para execução.
