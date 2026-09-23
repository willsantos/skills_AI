---
name: morcegador
description: Aplicar a menor mudança correta em tarefas de programação e revisar diffs para remover complexidade desnecessária. Use quando o usuário pedir implementação, correção, refatoração, simplificação ou revisão de código com foco em reuso, manutenção e escopo enxuto; também quando invocar Morcegador pelo nome. Do NOT use for criar novas arquiteturas completas do zero ou quando for explicitamente pedido um redesign abrangente.
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
---

# Morcegador

Buscar o menor conjunto de mudanças que resolve o requisito com clareza e preserva o comportamento necessário. Medir simplicidade pela complexidade mantida, nunca pela contagem de linhas.

## Antes de editar

Entender o requisito, o fluxo afetado e as convenções do projeto. Percorrer esta escada em ordem e parar na primeira solução suficiente:

1. A mudança precisa existir? Verificar se configuração, remoção ou comportamento existente já satisfaz o pedido.
2. O projeto já resolve isso? Buscar componente, serviço, helper, middleware ou padrão equivalente antes de criar outro.
3. A linguagem resolve? Preferir biblioteca padrão e recursos idiomáticos.
4. O framework ou a plataforma resolve? Usar capacidades nativas antes de acrescentar uma camada própria.
5. Uma dependência instalada resolve? Reusar antes de adicionar pacote.
6. É possível adaptar o código existente? Preferir mudança localizada e API mínima.
7. Se código novo for necessário, qual é a implementação mínima correta? Implementar apenas os cenários exigidos, com nomes claros.

Não transformar a escada em ritual de documentação. Registrar sucintamente a decisão apenas quando ela explicar uma escolha relevante.

## Durante a implementação

- Preservar convenções, contratos públicos e comportamento fora do escopo.
- Evitar wrappers sem função, helpers de uso único sem ganho de clareza, interfaces para uma única implementação, factories desnecessárias, DTOs redundantes, dependências triviais e fallbacks para estados impossíveis.
- Não comprimir código legível em expressões difíceis só para reduzir linhas. Extrair uma função quando ela dá nome a uma regra importante, elimina duplicação real ou facilita teste relevante.
- Manter validação em fronteiras, segurança, tratamento de dados externos, transações, concorrência, acessibilidade e prevenção de perda de dados. Não remover essas proteções para diminuir o diff.
- Respeitar requisitos não funcionais e restrições explícitas do usuário; a menor mudança incorreta não é solução.

## Revisão do diff

Depois de implementar, examinar o diff como em um PR: **o que eu pediria para apagar?** Revisar arquivos novos, APIs, dependências, duplicação, código defensivo excessivo e alterações fora do escopo. Remover o que for dispensável sem sacrificar correção ou legibilidade.

Executar verificação proporcional ao risco e relatar o que foi alterado, o que foi verificado e qualquer limitação material. Não acrescentar testes que apenas espelhem a implementação; testar comportamentos relevantes quando houver risco concreto.

Para calibrar decisões ambíguas, consultar [exemplos](references/exemplos.md).
