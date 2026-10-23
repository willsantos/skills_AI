---
name: rails8-hotwire-agent
description: "Desenvolver e manter aplicações Rails 8 com Hotwire, Active Record e Active Job. Use when implementar CRUD Rails, corrigir Turbo Frames/Streams, adicionar Stimulus, revisar autorização, migrations, jobs ou preparar deploy Rails com Kamal. Do NOT use for aplicações não Rails, dúvidas genéricas de Ruby, interfaces SPA sem integração Rails ou administração de VPS sem contexto de aplicação Rails."
compatibility: "Rails 8.x; Rails 8.1 recomendado em 2026; Ruby e gems conforme Gemfile.lock; Linux/macOS; banco conforme projeto; Kamal opcional"
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.1.0"
  language: "pt-BR"
  updated: "2026-10-23"
---

# Rails 8 + Hotwire | Skill de desenvolvimento por agentes

## Objetivo e hierarquia

Construir e manter software Rails **simples de entender, fácil de testar, seguro para evoluir e econômico de operar em VPS Linux**. Favorecer o Rails idiomático e as capacidades do framework antes de criar abstrações. O objetivo não é produzir o mínimo de arquivos, mas o mínimo de complexidade **compatível com os requisitos**.

Prioridades, nesta ordem:
1. Correção de negócio, segurança de acesso e integridade dos dados.
2. Seguir a implementação e as convenções **já existentes no repositório**.
3. Testes que verificam o comportamento, incluindo falhas e permissões.
4. Clareza e localização do código por recurso/domínio.
5. Recursos nativos do Rails e Hotwire antes de novos pacotes/serviços.
6. Eficiência operacional e deploy reproduzível em VPS.
7. Otimização medida, sem antecipar microserviços e infraestrutura complexa.

> Respeite solicitações explícitas do projeto e restrições de versões. Esta skill é um padrão de decisão, não uma autorização para reescrever código existente.

## Antes de modificar qualquer coisa

1. Leia `AGENTS.md`/`CLAUDE.md` e a documentação do projeto, se houver; verifique `Gemfile`, `Gemfile.lock`, `config/routes.rb`, `config/database.yml`, `config/application.rb`, `config/deploy.yml`, `test/` e estrutura de `app/`.
2. Identifique Rails/Ruby efetivos, DB (SQLite/PostgreSQL), adapter de jobs, autenticação, autorização, asset pipeline e forma de deploy. **Não presuma** que as opções-padrão não foram alteradas.
3. Localize a jornada de usuário e o código existente do recurso; antes de gerar classe/migration/gem, pesquise se o Rails ou o projeto já resolve o caso.
4. Defina mudança mínima, invariantes, superfícies afetadas, testes relevantes e riscos. Para tarefas complexas, registre plano curto antes de codificar.
5. Não adicione gems, serviços, padrões, migrations destrutivas ou alterações no deploy sem necessidade comprovada.

## Arquitetura padrão

Adote **monólito modular pragmático, orientado por domínio e operações**, preservando os diretórios convencionais de Rails. Não imponha pastas `features/` artificiais se elas piorarem as convenções. Use namespaces (`Billing::Invoice`, `Admin::InvoicesController`) para domínios reais e extraia componentes apenas quando fizer sentido.

**Fluxo preferido**: `rota REST → controller enxuto → model/objeto de domínio → Active Record → view/partial → Turbo`, com Stimulus apenas para comportamento local do navegador.

- Controllers: autenticação, autorização, parâmetros fortes, orquestração HTTP, resposta e códigos de status; não conter regras de domínio extensas.
- Models: associações, validações, scopes, invariantes, transições; evitar *fat model* sem limite.
- Service/operation object (ex.: `Orders::Checkout`): somente para fluxo de negócio não trivial, transações complexas, múltiplas entidades ou integração externa; uma finalidade, método público claro.
- Query object: somente para consulta complexa reutilizada. Para consultas simples, `scope`, relation e `includes` bastam.
- Form object: somente quando o formulário combina modelos ou representa fluxo independente de persistência.
- Jobs: I/O demorado, execução assíncrona, tarefas agendadas. Enfileirar IDs ou argumentos simples; recuperar registros durante a execução.
- Views/partials: HTML é a fonte primária da UI; componentes somente quando eliminam duplicação real.

**Não usar por padrão:** Clean Architecture cerimonial, repository genérico sobre Active Record, camadas DTO→Mapper→Service→Repository para CRUD, CQRS/MediatR genéricos, serializers JSON para a UI Hotwire, event bus interno, microserviços, Redis, React/Next.js, Sidekiq, ViewComponent ou qualquer gem sem requisito.

**Não proibir:** abstrações justificadas por regras complexas, integração externa, reuso comprovado, isolamento exigido ou requisitos de escala. Explicitar por que são necessárias.

Leia [Arquitetura e convenções](references/architecture.md) para estrutura por domínio, responsabilidades e critérios de extração.

## Hotwire como padrão de frontend

Escolha a técnica **mais simples**:
1. Navegação e formulários comuns: Rails views + **Turbo Drive** (sem JS customizado).
2. Atualizar uma região com seu próprio link/form: **Turbo Frames**.
3. Atualizar regiões após uma ação ou eventos: **Turbo Streams**; somente usar broadcasts quando múltiplas sessões precisam receber atualizações.
4. Comportamento local (menus, diálogo, clipboard, filtros de apresentação): **Stimulus** com `targets`, `values` e `actions`, sem estado de negócio duplicado no browser.
5. JS adicional apenas quando Hotwire/Stimulus não resolverem bem; documentar o motivo.

- Páginas devem continuar funcionais com resposta HTML normal sempre que viável (progressive enhancement).
- Formulários inválidos retornam status `422 Unprocessable Entity` (ou o comportamento suportado na versão do projeto), mantendo erros e campos.
- Em redirects após escrita, preferir `303 See Other`. Ao atualizar conteúdo de um frame, usar `update`; `replace` exige recriar o wrapper com o mesmo ID. Testar duas submissões consecutivas e uma inválida.
- IDs de Turbo Frames/Streams estáveis e únicos (`dom_id`), partials com nomes consistentes, sem duplicar marcação.
- Não enviar HTML privado para canais de broadcast amplos; autorizar a consulta **e** o escopo da transmissão.
- Testar redirecionamentos, respostas Turbo, falhas de validação e fluxos críticos no navegador.

Leia [Hotwire, Turbo e Stimulus](references/hotwire.md) quando houver trabalho de UI.

## Persistência, filas e integrações

- Preferir Active Record e migrations reversíveis/compatíveis com versões adjacentes do app; índices e constraints no banco para invariantes essenciais.
- Evitar N+1 com `includes`, `preload` ou `eager_load` conforme medição/consulta.
- Multi-tenant: toda consulta, alteração, job e broadcast deve respeitar escopo de conta/usuário.
- Para background: usar Active Job e **Solid Queue** quando for o backend configurado. Não instalar Redis/Sidekiq por reflexo.
- Jobs devem ser idempotentes, ter timeouts/retries proporcionais e observabilidade. Não assumir atomicidade entre transação do app e fila em outro banco.
- Antes de alterar concorrência, unicidade, pagamentos ou entrega confiável, ler `references/consistency.md`; definir conflitos, deduplicação persistida e recuperação após falha parcial.
- Preferir Active Storage, Action Mailer, Action Cable/Solid Cable e Solid Cache quando cobrirem o requisito e estiverem configurados.
- Integração com IA: encapsular provedores em um adapter pequeno, guardar segredos fora do código, validar entradas/saídas, impor timeout/custo/limites, evitar dados sensíveis em prompts/logs, medir qualidade e gasto; não introduzir Python/Rust sem necessidade.

Leia [Persistência, jobs e integrações](references/data-jobs.md) para detalhes.

## Segurança e verificações: critérios obrigatórios

- Autenticação **não é** autorização. Verificar acesso por registro, recursos e tenant; Rails 8 possui generator de autenticação, mas políticas são responsabilidade da aplicação.
- Usar strong parameters, escapes padrão do ERB, consultas parametrizadas, CSRF, proteção de sessão, validação de upload e segredos/credentials seguros.
- Nunca executar comandos destrutivos de produção, migrar banco produtivo, fazer deploy, apagar dados ou alterar DNS sem confirmação explícita e mecanismo de recuperação.
- Testar casos de sucesso, validação, autorização negativa e regressões. Preferir Minitest padrão se projeto não usar outra suíte.
- Antes de concluir, executar os comandos realmente disponíveis: `bin/rails test`, `bin/rails zeitwerk:check`, `bin/rubocop`, `bin/brakeman`; incluir `bin/rails test:system` para jornadas críticas ou interatividade alterada. Se `bin/ci` existir, priorizar o pipeline do projeto. **Não alegar testes que não foram executados.**
- Para verificações locais, usar `scripts/check.sh` desta skill: seleciona Minitest/RSpec e rejeita execução sem testes. Revisar `bin/ci` antes de autorizar modo `ci`; exit code zero sozinho não comprova cobertura nem segurança de ambiente.

Leia [Segurança, testes e revisão](references/security-quality.md).

## VPS Linux e deploy

Padrão preferido para Rails 8 convencional: **imagem Docker versionada + Kamal + VPS Linux**, usando o proxy gerenciado pelo Kamal quando adequado. `systemd`/Docker Compose são válidos se já existentes. Não adicionar proxy extra sem necessidade. Escolher SQLite ou PostgreSQL conforme concorrência, backup e operação, sem presumir que PostgreSQL já está instalado.

- Fazer build e testes fora da VPS quando possível; implantar artefato versionado.
- Configurar HTTPS, health check, restart, logs, retenção, backups externos e **teste de restore**; monitorar RAM, disco, conexões e fila.
- Não expor banco/filas à internet pública. Usar usuário com privilégios mínimos e secrets fora do repositório.
- Para workers, considerar execução no Puma apenas quando adequado ao perfil de carga; separar processo para jobs longos ou com risco de afetar web.
- Aplicar estratégia de migrations compatíveis entre versões. **Rollback de imagem não reverte esquema/dados.**
- Não assumir zero downtime, persistência ou segurança apenas porque Kamal foi instalado; verificar a configuração real.

Leia [VPS Linux, Kamal e operação](references/vps.md) ao preparar deploy/infra.

## Procedimento obrigatório do agente por tarefa

1. **Descobrir:** requisitos, comportamento anterior, rotas, controllers/models/views/jobs existentes e convenções do repositório.
2. **Planejar:** identificar menor mudança segura, endpoints/partials e testes afetados; riscos de permissão, concorrência, jobs e migrations.
3. **Implementar:** usar Rails idiomático; alterar o mínimo de arquivos coerente com o recurso; não recriar funcionalidades nativas.
4. **Verificar:** testes relevantes, lint, carregamento, segurança e fluxo Hotwire no navegador quando aplicável; corrigir até passar.
5. **Revisar:** procurar N+1, dependências novas, acessos sem escopo, alterações incompatíveis no schema e lógica duplicada entre JS/Ruby.
6. **Entregar:** informar arquivos modificados, decisões, comandos **de fato executados**, resultado, riscos, itens não verificados e plano de rollback quando necessário.

Se faltar acesso ao banco/browser/rede, declarar a limitação e fornecer os comandos de reprodução. **Nunca inventar saída, resultado de teste, benchmark ou comportamento de gem.**

Leia [Fluxo de trabalho para agentes](references/agent-workflow.md) para instruções de execução e critérios de aceite.

## Exemplos de uso e recursos sob demanda

- **Pedido:** "Corrija formulário Turbo que para após primeira criação". **Resultado esperado:** preservar frame, erros e valores; system test com duas criações e validação inválida. Ler `references/hotwire.md`.
- **Pedido:** "Impeça usuário de outra conta de acessar uma tarefa". **Resultado esperado:** escopo autorizado no servidor, teste negativo de leitura/escrita e ausência de vazamento. Ler `references/security-quality.md`.
- **Pedido:** "Torne job seguro para reexecução". **Resultado esperado:** política persistida de idempotência e efeitos externos, não apenas `return if processed?`. Ler `references/consistency.md`.
- Ao instalar/adaptar instruções no projeto, usar `assets/AGENTS.template.md`; ao revisar entrega, usar `assets/PR_CHECKLIST.template.md`.
- Ao modificar ou validar o exemplo, ler `references/testing-example.md`; criar sandbox novo com `scripts/verify-example.py`. Código e testes completos ficam em `assets/example/`, sem autenticação fictícia no app publicado.
- Ao alterar gate, executar `scripts/test_check.py`; `scripts/assert-test-count.rb` valida os resumos dos runners usados por `scripts/check.sh`.
- Ao avaliar ativação e aderência da skill, ler `evals/scenarios.md`. Testar código de exemplo não comprova comportamento do agente.

## Exemplo de estrutura: começo pequeno

```text
app/
  controllers/
    projects_controller.rb
    invoices_controller.rb
  models/
    project.rb
    invoice.rb
  views/
    projects/{index.html.erb,_project.html.erb,_form.html.erb,...}
    invoices/{index.html.erb,_invoice.html.erb,...}
  javascript/controllers/
    autosave_controller.js
  jobs/
    invoices/send_receipt_job.rb
  services/                    # opcional; só operações não triviais
    invoices/issue.rb
config/routes.rb
db/migrate/
test/{models,controllers,integration,system,jobs}/
```

Quando surgirem limites reais de domínio, introduzir namespaces **coerentes em controller/model/view/job**, respeitando Zeitwerk. Não criar um framework interno de slices: Rails já organiza boa parte das responsabilidades.

## Fonte da verdade

O **repositório e os testes** prevalecem sobre exemplos da skill. Depois, a documentação oficial da versão efetiva. Referências principais:

- Rails: https://guides.rubyonrails.org/
- Hotwire/Turbo: https://turbo.hotwired.dev/handbook/introduction
- Stimulus: https://stimulus.hotwired.dev/handbook/introduction
- Kamal: https://kamal-deploy.org/docs/
- Agent Skills: https://agentskills.io/specification

Quando houver dúvida sobre uma API, verifique a documentação e o `Gemfile.lock` antes de usá-la.
