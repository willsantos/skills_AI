# Orientações de agentes (modelo, adapte ao projeto)

- Backend .NET: usar `.agents/skills/dotnet-modular-vertical-slices/SKILL.md`.
- Frontend novo e não decidido: executar `.agents/skills/frontend-architecture-selector/SKILL.md` e registrar `docs/adr/`.
- Integração HTTP, auth, contratos e deploy: executar `.agents/skills/dotnet-frontend-integration/SKILL.md`.
- Se Vue: `.agents/skills/dotnet-vue-vite/SKILL.md`. Se Angular: `.agents/skills/dotnet-angular/SKILL.md`.
- Não rediscutir framework a cada feature; respeitar ADR. Não trocar stack sem pedido explícito.
- OpenAPI do backend é fonte de verdade do contrato. Nenhum frontend implementa regras de negócio nem autoriza recursos em definitivo.
- Executar builds, linters, typecheck e testes antes de declarar entrega; se indisponível, declarar a limitação.
- Não alterar infraestrutura, produção, migrações destrutivas ou secrets sem autorização.
