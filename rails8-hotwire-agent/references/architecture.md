# Arquitetura Rails idiomática, sem Clean Architecture cerimonial

## Regra de decisão

Rails usa MVC por convenção. Organize recursos coesos no mesmo domínio **por nomenclatura e namespaces**, sem deslocar todas as operações para camadas próprias. `app/controllers`, `app/models`, `app/views`, `app/jobs` e `test` são os pontos de partida.

O padrão desejado é **monólito modular pragmático**: fronteiras conceituais claras entre áreas de negócio, sem criar vários serviços ou gems internos na primeira versão.

## Padrões por tamanho de operação

| Operação | Estrutura suficiente |
|---|---|
| CRUD simples | Routes + controller + model + views/partials + testes |
| Validação/invariante de uma entidade | Model, validations e métodos de domínio |
| Consulta simples | Scopes/relation com índices adequados |
| Consulta complexa compartilhada | Query object específico |
| Transação com múltiplos agregados e efeitos | Service/operation object específico |
| Envio de e-mail ou processamento assíncrono | Active Job + backend já configurado |
| Formulário que orquestra vários modelos | Form object somente se reduzir complexidade |
| Integração externa | Cliente/adapter pequeno, testável e com timeout |
| Domínio grande ou múltiplos times | Namespaces e limites de dependência; considerar engines somente se houver benefício demonstrado |

## Responsabilidades

### Controller

- Recebe request e parâmetros fortes; autentica, autoriza e determina escopo de dados.
- Invoca operações persistentes e escolhe resposta (`redirect_to`, `render`, Turbo/HTML).
- Não implementa algoritmos de negócio complexos, processamento demorado ou múltiplos efeitos colaterais intrincados.

### Model Active Record

- Associações, constraints de domínio da entidade, validations, scopes, métodos com nomes de negócio.
- Não centralizar todos os workflows globais em um model gigante.
- Preferir `save!` quando falha precisa interromper uma transação; tratar erros de validação em boundary HTTP.

### Service/operation object

- Usar somente quando existe uma operação com começo, fim e efeitos claros.
- Interface pública pequena, por exemplo `Invoices::Issue.call(invoice:, actor:)` ou instância `#call`.
- Sem `BaseService`, `IService`, pipelines/registries genéricos por antecipação.
- Passar dependências explícitas somente quando elas facilitam isolamento, testes ou integração externa.
- Use transações breves. Nunca abra transação de banco envolvendo chamada de rede demorada.

### View/partial

- Fonte de apresentação em HTML server-side. Reusar partial quando uma região aparece em mais de um lugar ou é alvo de Turbo Stream.
- Evitar `helper` genérico gigantesco e lógica SQL em views.

## Exemplo de organização quando a aplicação crescer

```text
app/
  controllers/
    billing/invoices_controller.rb
    billing/payments_controller.rb
    catalog/products_controller.rb
  models/
    billing/invoice.rb
    billing/payment.rb
    catalog/product.rb
  views/
    billing/invoices/
    billing/payments/
    catalog/products/
  jobs/
    billing/send_invoice_job.rb
  services/
    billing/issue_invoice.rb       # somente se necessário
  javascript/controllers/
    clipboard_controller.js
```

Os nomes exatos das classes, rotas, tabelas e associações precisam seguir as convenções de namespace e inflection do projeto. Não mova código existente para namespaces como pré-requisito de uma mudança simples.

## Encapsulamento de domínio: progressão

1. Primeiro, convenções e ownership explícito do domínio (quem possui qual dado).
2. Depois, namespaces, API pública e testes que exercitam os limites.
3. Em sistemas grandes, limitar acessos entre domínios via pacotes/engines/ferramentas de arquitetura se a equipe precisar de enforcement real.
4. Extrair serviço só diante de requisitos de escala, deploy ou isolamento incompatíveis com o monólito.

`app/services` é uma convenção da equipe, não um novo tipo obrigatório do Rails. Verificar se caminhos customizados são autoloaded pelo Zeitwerk; executar `bin/rails zeitwerk:check`.

## Anti-patterns para agentes

- Criar cinco classes quando um método model/endpoint e testes resolvem o fluxo.
- Inventar arquitetura paralela à do Rails antes de consultar a API nativa.
- Usar callbacks complexos para efeitos externos implícitos quando operação explícita é mais previsível.
- Controllers cheios de regras críticas ou models globais com responsabilidades de múltiplos domínios.
- Testes que apenas espelham implementação interna em vez de confirmar comportamento.
- Serviços com `call` genérico em todo CRUD sem valor de composição.

## Checklist de mudança

- Posso encontrar este recurso pelo nome do domínio?
- A responsabilidade ficou na camada correta **sem cerimônia desnecessária**?
- Há validações e constraints no banco quando apropriadas?
- O actor/tenant foi autorizado e escopado?
- O código novo segue convenções existentes e tem teste de regressão?
