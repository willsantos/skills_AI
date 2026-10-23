# Workflow para desenvolvimento por agentes

## Ao receber uma tarefa

1. Descobrir versão de .NET (global.json / TargetFramework), solution, entry point, organização e pacotes existentes.
2. Buscar implementações semelhantes com ferramenta de busca do repo; reutilizar padrões locais.
3. Identificar módulo proprietário, input/output, authn/authz, invariantes, alteração de banco, concorrência e impacto em clientes.
4. Formular plano curto: lista de arquivos a criar/mudar, definição de pronto, testes e risco.
5. Se precisar de requisitos não presentes que alteram segurança/persistência/contrato público, perguntar antes de executar mudança irreversível; em tarefas reversíveis, adotar hipótese explícita.

## Implementação de nova feature

1. Definir comportamento e critérios de aceitação independentes de implementação.
2. Definir Request e Response em fronteira HTTP; validar formato, faixas, paginação e payload.
3. Verificar identidade, papéis e ownership/tenant no servidor. Não confiar em ID de tenant enviado pelo cliente sem autorizar.
4. Implementar handler da slice. Simples: lógica local. Complexo: delegar regra ao modelo/serviço de domínio; manter o endpoint fino o suficiente para ser legível.
5. Persistir com DbContext do módulo; uma unidade de trabalho por operação. Projetar consultas para DTO e usar `AsNoTracking` em leitura.
6. Para side effects externos, avaliar necessidade de idempotência, retry, timeout, circuit breaker e outbox.
   - Se houver concorrência, unicidade ou falhas parciais, aplicar `consistency.md` e definir política antes de implementar. Para dinheiro, alinhar faixa/escala entre contrato, domínio e banco.
7. Registrar endpoint em `Module.MapEndpoints(...)` e suas dependências em `Module.AddServices(...)` (nomes apenas exemplificativos, seguir repo).
8. Escrever testes de sucesso, inputs inválidos, acesso negado, invariantes e persistência. Atualizar documentação/OpenAPI.
9. Executar build, testes e verificação de arquitetura. Não usar flags para esconder erros/avisos.

## Alteração em feature existente

- Identificar contrato anterior e usuários da operação; preservar compatibilidade salvo pedido explícito.
- Reproduzir defeito com teste que falha ou diagnóstico verificável antes de corrigir, quando viável.
- Fazer a menor mudança coerente com o design, sem refatorar o resto do projeto.
- Verificar regressão e migrações quando alterou dados.

## Refatoração arquitetural

- Mapear dependências reais, priorizar um módulo/feature por vez e estabilizar testes antes de mover código.
- Preferir refatoração incremental, preservar rotas e formatos públicos.
- Não converter tudo para MediatR, repositories, CQRS pleno, abstrações genéricas ou microsserviços por preferência pessoal.

## Entrega da tarefa

Relatar sempre: **o que mudou**, **por quê**, **qual contrato/migration foi afetado**, **quais verificações foram executadas**, **o que não foi testado** e **riscos restantes**. Se não houver SDK ou banco disponível, declarar limitação, sem afirmar build/teste aprovado.
