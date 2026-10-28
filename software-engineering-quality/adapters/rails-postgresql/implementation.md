# Adapter Rails 8 + PostgreSQL (+ Hotwire)

## Onde ficam as responsabilidades

- Controller: autenticação, autorização, strong params e resultado/redirect/stream; não tomar preço ou permissão como verdade do browser.
- Model: validações e regras de domínio coesas, associations e scopes de autorização; callbacks complexos não substituem casos de uso explícitos.
- Service/command object: apenas quando um workflow longo de múltiplos modelos/integrações justifica; evitar criar um service para cada método trivial.
- Active Record migrations: índices/constraints reais, não confiar apenas em `validates` para concorrência.
- Hotwire/Turbo: melhora UX, mas não protege autorização e não cria fronteira de confiança.

## UPDATE condicional e transação

```ruby
quantity = Integer(params.require(:quantity))
raise ArgumentError, 'invalid quantity' unless quantity.positive?

Order.transaction do
  affected = Product.where(id: product_id)
    .where('stock >= ?', quantity)
    .update_all(['stock = stock - ?', quantity])

  raise ActiveRecord::Rollback if affected != 1

  Order.create!(user: current_user, product_id: product_id, quantity: quantity)
  # Calcular e registrar preço a partir do servidor antes do commit.
end
```

**Exemplo ilustrativo:** `ActiveRecord::Rollback` é capturado pela transação e pode não ser repropagado; retorne resultado de falha explicitamente ao controller. `update_all` bypassa callbacks/validations e não atualiza `updated_at` automaticamente. Não misturar com instância Active Record carregada/desatualizada sem recarregar. Para locks de linha em workflow maior, usar `with_lock` ou `lock` dentro de transação e controlar ordem de locks.

## Eventos duplicados

- Índice único composto em `processed_events(provider, event_id)`.
- Dentro da mesma `ActiveRecord::Base.transaction`, inserir marker com mecanismo `ON CONFLICT DO NOTHING` ou `create_or_find_by!` corretamente configurado e executar transição do pedido.
- `find_or_create_by` sozinho é sujeito a corrida quando não há índice único.
- Checar assinatura do webhook e estado do pagamento antes de registrar efeitos.
- Para e-mail/job após o commit, `after_commit` evita efeitos em transação revertida, mas **não garante entrega** se o processo cair após commit. Outbox quando a entrega for essencial.

## Autorização e teste

- Consultar `current_user.orders.find(params[:id])` ou policy equivalente por recurso; em multi-tenant aplicar escopo em cada query.
- Para regras SQL/locks usar PostgreSQL real e conexões distintas nos testes de concorrência; não depender apenas de sqlite/teste de model.
- Testes de requisição (`request specs` / integration tests Rails) exercitam autenticação, controller, modelos e persistência; testes de sistema cobrem Turbo/Stimulus quando UI for crítica.
- RLS quando aplicável com roles adequadas, variável por transação e testes contra vazamento do pool.

Fontes: https://api.rubyonrails.org/classes/ActiveRecord/Locking/Pessimistic.html ; https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html
