# Segurança, testes e critérios objetivos de aceite

## Segurança de acesso

1. Autenticação identifica **quem** acessa; autorização decide **o que** pode fazer. O gerador `bin/rails generate authentication` do Rails 8 não substitui políticas de autorização de negócio.
2. Cada leitura e escrita de recurso privado deve ser escopada por usuário, conta ou organização. Evitar `Model.find(params[:id])` em recurso multitenant quando o escopo é `Current.account.models.find(...)`.
3. Testar usuário de outro tenant tentando consultar, alterar, exportar, baixar anexo e assinar broadcast privado.
4. Usar `params.require(...).permit(...)`, escape padrão em views, SQL parametrizado, anti-CSRF e cookies seguros.
5. Bloquear mass assignment de papel/permissão/tenant/owner e campos de estado críticos.
6. Nunca colocar tokens de API no JavaScript, no git, em logs ou em screenshots.
7. Sanitização de HTML não equivale a autorização; `html_safe`, `raw`, SQL interpolado e `send`/`constantize` a partir de entrada do usuário exigem revisão especial.
8. Para `Action Cable` e Turbo Streams, autenticar subscription e conferir tenant/canal. Não supor que um stream com nome de ID é privado por si só.
9. Toda ação destrutiva deve proteger CSRF e exibir confirmação apropriada; ações críticas também exigem autorização no servidor.

## Pirâmide pragmática de testes

- **Model tests**: invariantes, validações e transições de estado.
- **Controller/integration tests**: HTTP, autorização, parâmetros, redirects, Turbo Stream/HTML, falhas de validação.
- **Job tests**: enfileiramento, retry, idempotência, falha de serviços externos, permissões quando aplicável.
- **System tests**: jornadas críticas, Turbo Frames e interações Stimulus reais no navegador; não criar um E2E pesado para cada CRUD.
- **Regressão**: reproduzir o bug antes de corrigir sempre que viável.
- **Segurança estática**: RuboCop/Brakeman, sem silenciar alertas sem justificativa.

Priorizar Minitest e fixtures existentes; não instalar RSpec ou factories apenas por preferência. Se o projeto já usa RSpec, respeitar a suíte.

## Comandos

Primeiro conferir o que o repositório tem instalado:

```bash
bin/rails -v
bin/rails zeitwerk:check
bin/rails test
bin/rails test:system          # quando houver browser e testes de sistema
bin/rubocop                   # se existir
bin/brakeman -q               # se existir
bin/ci                        # se existir e for o pipeline definido pelo projeto
```

A skill inclui `scripts/check.sh` com modos `fast` e `full`. Ele falha quando checks obrigatórios existentes falham e explica checks ausentes; não modifica produção. Nunca executar `bin/rails db:prepare` em produção automaticamente.

## Definition of Done

- [ ] Comportamento pedido entregue sem mudança lateral injustificada.
- [ ] Requisitos de negócio e invariantes atendidos.
- [ ] Autorização e escopo de registros verificados com testes negativos.
- [ ] Requisições inválidas e exceptions tratadas conscientemente.
- [ ] Migrations compatíveis, índices/constraints/rollback considerados.
- [ ] Turbo e Stimulus validados em browser quando houve alterações na interação.
- [ ] Testes relevantes, Zeitwerk, lint e análise de segurança executados **ou impedimento declarado**.
- [ ] Sem dados sensíveis em logs, commits ou templates.
- [ ] Sem regressões evidentes, gems supérfluas ou infraestrutura desnecessária.
- [ ] Descrição final contém arquivos modificados, comandos executados, resultados e pontos em aberto.

Se a tarefa envolver produção, também verificar [VPS](vps.md) e pedir aprovação prévia para ações mutáveis.

Referências: https://guides.rubyonrails.org/security.html ; https://guides.rubyonrails.org/testing.html ; https://guides.rubyonrails.org/active_record_validations.html
