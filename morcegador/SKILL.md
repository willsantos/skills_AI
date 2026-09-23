---
name: morcegador
description: Aplicar a menor mudança correta em tarefas de programação e revisar diffs para remover complexidade desnecessária. Use quando o usuário pedir implementação, correção, refatoração, simplificação ou revisão de código com foco em reuso, manutenção e escopo enxuto; também quando invocar Morcegador pelo nome. Do NOT use for criar novas arquiteturas completas do zero ou quando for explicitamente pedido um redesign abrangente.
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.1.0"
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

## Alinhamento com `.specs`

Depois da escada e antes de editar, procurar spec só se o repositório tiver `.specs/`. Não assumir que existe. Não tratar README, comentário ou teste como spec.

1. Achar o arquivo em `.specs/` que cobre o fluxo afetado. Busca estreita: nome da feature, caminho alterado, aceite citado no pedido. Sem arquivo pertinente, seguir. Não inventar critério.
2. Confrontar a mudança mínima com o que a spec afirma: comportamento, contrato, invariante, fora de escopo. Três saídas:
   - **Alinha:** implementar. Não citar a spec no diff.
   - **Não cobre:** mudança fora do texto, sem negá-lo. Seguir. Não inchar a spec com o óbvio.
   - **Contradiz:** a mudança necessária nega regra, aceite ou invariante escrito.
3. Contradição bloqueia o código até o adendo. Não "corrigir" a spec em silêncio. Não enfraquecer a regra para o diff caber. Não implementar o contraditório e deixar a spec mentindo.
4. Adendo mínimo no mesmo arquivo, no ponto da regra contradita:
   - o que a spec dizia;
   - o que passa a valer e por que a mudança é necessária;
   - o que permanece. Não reescrever seções intocadas.
5. Se a necessidade não estiver clara, parar. Mostrar o trecho contradito e o adendo proposto. Esperar confirmação. Spec ambígua não é contradição: tratar como requisito incompleto.

## Durante a implementação

- Preservar convenções, contratos públicos e comportamento fora do escopo.
- Evitar wrappers sem função, helpers de uso único sem ganho de clareza, interfaces para uma única implementação, factories desnecessárias, DTOs redundantes, dependências triviais e fallbacks para estados impossíveis.
- Não comprimir código legível em expressões difíceis só para reduzir linhas. Extrair uma função quando ela dá nome a uma regra importante, elimina duplicação real ou facilita teste relevante.
- Manter validação em fronteiras, segurança, tratamento de dados externos, transações, concorrência, acessibilidade e prevenção de perda de dados. Não remover essas proteções para diminuir o diff.
- Respeitar requisitos não funcionais e restrições explícitas do usuário; a menor mudança incorreta não é solução.

## Revisão do diff

Depois de implementar, examinar o diff como em um PR: **o que eu pediria para apagar?** Revisar arquivos novos, APIs, dependências, duplicação, código defensivo excessivo e alterações fora do escopo. Remover o que for dispensável sem sacrificar correção ou legibilidade.

Executar verificação proporcional ao risco. Não acrescentar testes que apenas espelhem a implementação; testar comportamentos relevantes quando houver risco concreto.

## Tratamento de erros e impasses

Quando a menor mudança encontrar impedimentos ou se a verificação falhar (if verification fails):

1. **Legado altamente acoplado:** Se a mudança mínima exigir refatorar múltiplos arquivos não relacionados, isole a intervenção com uma função pura ou adaptador local no ponto de chamada, sem iniciar refatoração em cascata.
2. **Testes pré-existentes com erro ou falha:** Identifique e reporte antes de alterar. Não corrija testes alheios ao escopo sem autorização explícita; apenas certifique-se de que a nova mudança não introduziu novos erros ou quebras.
3. **Requisito contraditório ou incompleto:** Pare antes de implementar código defensivo especulativo. Apresente as alternativas mínimas ao usuário e solicite desambiguação. Se a contradição for com `.specs/`, o adendo proposto faz parte dessas alternativas; não aplicar código nem adendo sem confirmação.

## Exemplo de aplicação e contrato de saída

### Exemplo (Example):
- **User says:** "Adicionar expiração no token de sessão do usuário."
- **Aplicação da escada:** O framework já suporta `maxAge` no cookie existente (degrau 4). Não criar tabela nova no banco nem middleware adicional.
- **Spec:** `.specs/auth.md` exige sessão sem expiração. A mudança nega essa regra. Adendo no mesmo arquivo: expiração passa a ser `maxAge` nativo; o restante do contrato de sessão permanece. Sem confirmação, não editar código.
- **Resultado esperado (Result):**

```text
- Decisão: Usado parâmetro nativo `maxAge` da sessão do framework existente.
- Spec: adendo em `.specs/auth.md` (regra de sessão sem expiração revogada; motivo: expiração exigida).
- Arquivos modificados: `.specs/auth.md`, `src/auth/session.ts` (+2 linhas).
- Verificação: Testes unitários de auth executados (`npm test auth`). Sem quebras.
```

Para calibrar decisões ambíguas adicionais, consultar [exemplos](references/exemplos.md).
