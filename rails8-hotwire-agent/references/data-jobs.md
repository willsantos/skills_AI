# Active Record, filas, armazenamento e serviços externos

## Banco

- **Respeitar o banco existente**; novos projetos pequenos podem aproveitar SQLite com backup/concorrência adequados. PostgreSQL é recomendável se houver muitos usuários simultâneos, consultas complexas, várias instâncias ou requisitos operacionais específicos.
- Não alterar a tecnologia do banco por preferências da skill.
- Validations em models dão feedback; `null: false`, unique indexes e foreign keys mantêm integridade mesmo em concorrência.
- `validates :field, uniqueness: true` sozinho não evita corridas; exija índice único.
- Mudanças de schema em VPS: preferir expand/contract; backfill em job quando pesado; primeiro compatibilidade entre versões e só depois remoção de colunas antigas.
- Proibir `db:reset`, `db:drop`, `db:schema:load` e equivalentes em produção sem aprovação e plano explícito de recuperação.
- Prevenir N+1 com consultas adequadas, verificar queries em logs/testes, não usar `includes` indiscriminadamente.
- Utilizar transações para mudanças relacionadas; manter transações curtas e não segurar locks durante APIs remotas.
- `update_all`, `insert_all`, `update_columns` e SQL direto podem ignorar validations/callbacks. Revisar constraints, autorização/tenant e efeitos perdidos antes de usá-los. Para conflitos e efeitos externos, seguir `consistency.md`.

## Active Job / Solid Queue

Rails 8 já contempla Solid Queue como backend comum/default. Confirmar `config.active_job.queue_adapter`, `config/queue.yml` e `config/database.yml` antes de alterar.

- Use `perform_later(record.id)` em vez de serializar grandes árvores de objetos. GlobalID funciona, mas IDs explícitos simplificam reexecução e tratamento de registros removidos.
- Jobs precisam ser **idempotentes**: retries podem ocorrer após falha no meio da operação.
- Use `retry_on`/`discard_on` criteriosamente; registre falhas e limite chamadas externas.
- Enfileirar após commit para operações que precisam de dados já persistidos. Verificar `enqueue_after_transaction_commit` no projeto quando pertinente.
- Não presumir que enqueue de Solid Queue é atômico com o commit da aplicação: o Rails 8 usa **banco de fila separado por padrão**, e configurações podem mudar. Outbox transacional ou outro mecanismo quando a atomicidade negócio/fila for crítica.
- Jobs de processamento pesado devem usar workers separados se concorrem por RAM/CPU com requests web.
- Monitorar tamanho/atraso da fila, tentativas, erros, tempo de execução e processadores ativos.
- Agendamento recorrente: `config/recurring.yml` se Solid Queue do projeto o suportar; evitar cron do servidor duplicado sem motivo.

Exemplo mínimo:

```ruby
class GenerateReportJob < ApplicationJob
  queue_as :default
  retry_on Net::ReadTimeout, wait: 10.seconds, attempts: 3

  def perform(report_id)
    report = Report.find_by(id: report_id)
    return unless report
    return if report.generated?

    report.generate! # método de domínio idempotente
  end
end
```

A implementação de `generate!` e seus efeitos devem ser idempotentes de verdade; a verificação booleana acima **não protege corrida** sem controle transacional/lock/constraint adequado.

## Active Storage e anexos

- Reusar Active Storage antes de criar armazenamento próprio.
- Verificar validação de tamanho/tipo, permissão de download e proteção de anexos sensíveis.
- Não confiar no content-type informado pelo cliente; não expor blobs sem autorização.
- Controllers padrão de Active Storage são públicos; autenticação no `ApplicationController` não os protege automaticamente. Para anexos privados, implementar controllers autenticados/escopados e desabilitar rotas padrão quando adequado (`config.active_storage.draw_routes = false`), preservando as rotas autenticadas necessárias. URL assinada é acesso por posse do link, não autorização por usuário; não confundir expiração da URL do serviço com permanência do signed ID.
- Testar acesso direto à URL do blob por anônimo e usuário de outro tenant, não somente página que contém o link. Rever cache/proxy/CDN e possibilidade de compartilhamento da URL após autenticação.
- Para VPS, preservar arquivos em volume persistente ou usar object storage externo e backup correspondente.

## IA e serviços externos

- Encapsular integração em `app/services/ai/` (ou convenção atual) apenas se precisar de isolamento e mocks.
- Centralizar timeout, retries com backoff e circuit-breaker conforme necessidade; limites de tokens/custo e política de retenção.
- Respostas de modelo são **dados não confiáveis**, validar estrutura e permissões de ações antes de persistir/executar.
- Não fornecer segredos, chaves, tokens, dados sensíveis desnecessários em prompts/logs.
- Preferir jobs e atualizações Hotwire para chamadas lentas; endpoint web não deve esperar indefinidamente.
- Agentes autônomos não executam ações financeiras, deletações ou alterações irreversíveis sem autorização explícita e trilha de auditoria.

Documentação: https://guides.rubyonrails.org/active_record_basics.html ; https://guides.rubyonrails.org/active_job_basics.html ; https://guides.rubyonrails.org/active_storage_overview.html
