# Arquitetura e limites de módulos

## Estrutura inicial sugerida

```text
src/App.Api/
  Program.cs
  Modules/
    Catalog/
      CatalogModule.cs
      Features/
        CreateProduct/CreateProduct.cs
        GetProduct/GetProduct.cs
      Domain/Product.cs
      Infrastructure/CatalogConfiguration.cs
    Orders/
      OrdersModule.cs
      Features/CreateOrder/CreateOrder.cs
      Domain/Order.cs
  Persistence/AppDbContext.cs
  Infrastructure/Errors/
tests/
  App.UnitTests/
  App.IntegrationTests/
  App.ArchitectureTests/
```

Essa é uma estrutura inicial, **não** um requisito para reorganizar projetos existentes. Feature pode ser um arquivo ou uma pasta conforme tamanho. Não é necessário criar `Infrastructure` nem `Domain` vazios em cada módulo. Nunca iniciar com quatro projetos por camada apenas para simular Clean Architecture.

## Regras de ownership

- Nomear módulos pelo domínio, não por tecnologia. Cada entidade/tabela tem um módulo responsável por alterá-la.
- No estágio de projeto único, `AppDbContext` compartilhado é uma conveniência, mas seu uso deve ficar dentro da slice/módulo autorizado. Não atravessar módulos via `Include` nem navegar entidades alheias.
- Contexto compartilhado e pastas oferecem modularidade por convenção, não isolamento forte. Se isolamento verificável for requisito inicial, separar assemblies e contratos desde o início; não esperar violações recorrentes. Ver exemplo em `example-module-contract.md`.
- Quando a violação for recorrente, promover módulos a projetos separados com tipos `internal`, interfaces públicas pequenas e, se adequado, DbContexts específicos. Múltiplos DbContexts podem usar o mesmo PostgreSQL com ownership de schemas/tabelas definido.
- Outra feature do mesmo módulo pode compartilhar um serviço de domínio/consulta quando há lógica efetivamente reutilizada; não antecipar service para toda rota.
- Comunicação síncrona: contratos públicos do módulo provedor. Comunicação assíncrona: evento de integração + outbox quando consistência/publicação confiável forem requisitos. Não usar eventos para mascarar uma chamada local simples.
- Proibir dependência circular entre módulos. Se dois módulos dependem mutuamente dos internos um do outro, rever fronteiras e contratos.

## Camadas apenas quando resolvem uma necessidade

- **HTTP:** Request/Response, rotas, authn/authz, validação de formato.
- **Application/slice:** orquestração transacional, consulta EF, chamada de domínio e gateways.
- **Domain:** invariantes, conceitos e regras que não dependem de HTTP/EF/LLM.
- **Infrastructure:** banco, rede, storage, mensageria. Interfaces só quando o desacoplamento traz valor.

Não duplicar entidades em DomainModel, PersistenceModel, BusinessModel e APIModel sem razão concreta. Manter DTOs de borda separados de entidades, e projetar diretamente para respostas sempre que possível.

## Quando adicionar abstrações

| Sinal observável | Mudança indicada |
|---|---|
| Regra de negócio usada em vários fluxos | Método de domínio ou domain service |
| Integração externa simulada em testes | Interface pequena de gateway |
| Consultas complexas duplicadas | Query service específico |
| Módulos acoplados por tabelas internas | Contratos/projetos próprios |
| Várias persistências ou contratos de storage | Repository especializado, se justificar |
| Eventos com obrigação de entrega | Outbox + consumidor idempotente |
| Jobs demorados | Worker separado do HTTP |
| Escala/deploy independentes comprovadamente necessários | Extração de serviço após medir |

## Diretrizes para agentes

- Mapear efeitos colaterais antes de alterar schema ou contratos compartilhados.
- Limitar cada mudança ao módulo proprietário e às integrações necessárias.
- Manter nomes previsíveis (`CreateProduct`, `GetProduct`, `CatalogModule`) e não inventar helpers genéricos.
- Usar analyzers/architecture tests para impor dependências; pastas sozinhas não criam isolamento verificável.
- Documentar exceções temporárias de acoplamento com motivo e plano de remoção.
