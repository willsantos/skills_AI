# Coesão, separação de responsabilidades e arquitetura amigável a agentes

## Objetivo

Reduzir acoplamento e mudanças espalhadas sem multiplicar arquivos e interfaces desnecessários. Favorecer uma função/feature compreensível, testável e com comportamento explícito. Evitar que tamanho de arquivo seja a única métrica: coesão e complexidade são mais importantes.

## Distinguir responsabilidades

- **Borda HTTP/UI:** valida sintaxe e contrato, autentica, transforma erros em respostas; não escolhe preços nem controla acesso apenas pela UI.
- **Caso de uso:** autoriza operação de negócio, coordena consultas, transação, regras de domínio e eventos de saída.
- **Domínio:** invariantes, transições e cálculos que devem se manter independentes de detalhes de transporte; não precisa de uma hierarquia extensa de entidades se regras forem simples.
- **Persistência:** consultas, mapeamentos, locks, índices e integridade; acesso direto por ORM é permitido se coerente com o projeto.
- **Integrações:** clients, contratos, retries/timeouts e tratamento de falhas.

## Vertical Slices e monólitos modulares

Uma slice (por exemplo, `Orders/CreateOrder`) pode conter Endpoint, Request e Handler, compartilhando entidades e DbContext do módulo. Regras reutilizadas ficam em componente compartilhado **somente quando de fato reutilizadas**. Não forçar Controller + Service + Repository + UnitOfWork + Mediator se apenas repassam chamadas. Evitar dependência circular entre módulos; para comunicação, preferir APIs internas/eventos quando apropriado.

## Estratégia de alteração para agentes

1. Buscar contrato público e testes da feature antes de editar.
2. Identificar poucos arquivos com autoridade sobre a regra e ponto de persistência.
3. Alterar apenas o necessário, preservando APIs e convenções salvo motivo claro.
4. Isolar cálculo puro, se isso simplificar testes, mas manter fluxo de transação visível.
5. Manter decisão arquitetural explicitada em documentação relevante ou testes de arquitetura quando necessário.
6. Revisar se uma mesma regra foi duplicada no frontend/backend ou em diferentes handlers; regras de segurança são verificadas no servidor em cada entrada, mesmo quando UI repete validação por UX.

## Sinais de revisão

- Handler com muitos comportamentos independentes e várias razões para mudança.
- Cada feature depende de detalhes internos de outras features.
- Nomes vagos como `CommonService`, `GenericRepository`, `HelperUtils` com regras heterogêneas.
- Mapeamentos duplicados entre quatro modelos sem diferença semântica.
- Regras de negócio escondidas em callbacks da UI ou interceptores globais.
- Testes precisam mockar quase toda a aplicação para uma ação pequena.

## Contraexemplos

- Não separar uma função curta em cinco classes só para se adequar a um diagrama.
- Não introduzir CQRS/mensageria por padrão; há funções simples com consulta e atualização na mesma transação.
- Não colocar toda lógica no handler se a mesma invariante precisa ser preservada por vários fluxos; concentrar a regra no lugar certo.

## Evidência desejada

A alteração pode ser localizada; as dependências da slice são conhecidas; regras críticas têm fonte de verdade clara; contratos e testes protegem comportamento de implementação e agentes futuros.
