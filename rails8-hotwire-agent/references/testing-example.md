# Exemplo Rails executável e limites de verificação

Ler ao alterar exemplo Hotwire ou verificar publicação. `scripts/verify-example.py` cria uma aplicação Rails nova, usa generator oficial de autenticação, instala Turbo/Stimulus via importmap e copia código/testes de `assets/example/`. Não executar em aplicação existente: destino já existente é recusado.

## Pré-requisitos e execução

- Python 3, Ruby compatível com Rails 8.1, Bundler e Rails 8.1.3.1 já instalado para executar o generator. Chrome/Chromium e Selenium compatível são necessários apenas para `--system`.
- Versões diretas das gems são fixadas no script para testar o exemplo. Não representam recomendação de patches para produção. Dependências transitivas são registradas no `Gemfile.lock` gerado; preservar esse arquivo com evidências da execução.
- Sem `--local`, Bundler pode baixar/instalar gems no ambiente configurado. Usar ambiente Ruby descartável quando não quiser alterar gems locais. Script não instala o SDK/Ruby nem faz deploy.

```bash
python3 rails8-hotwire-agent/scripts/verify-example.py /tmp/opencode/rails-hotwire-example --local
```

Com navegador local:

```bash
CHROME_BIN=/usr/bin/google-chrome python3 rails8-hotwire-agent/scripts/verify-example.py /tmp/opencode/rails-hotwire-browser --local --system
```

`--local` limita instalação inicial ao cache; installers Rails também invocam Bundler e podem consultar registry. Não tratar essa opção como isolamento de rede. Se dependência não estiver em cache, omitir `--local` apenas após autorizar instalação. Selenium pode baixar driver/browser compatível; ambiente sem rede deve provisioná-los antes. Não desabilitar sandbox do navegador para contornar problemas de configuração.

Sandbox força `RAILS_ENV=test`, ignora DATABASE_URL herdado e usa somente SQLite em `storage/test.sqlite3`. Migrations alteram apenas esse banco novo de teste; timestamp da migration de tarefas é ajustado para suceder criação de users/sessions. Autenticação vem do Rails, não de um header/test endpoint incorporado à aplicação. Fixtures usam credenciais fictícias e exclusivas de teste. Testes de snapshot dos controllers de autenticação gerados são removidos somente do sandbox recém-criado; suíte incluída testa login e autorização do recurso, não todo fluxo de recuperação de senha.

## O que os testes demonstram

| Área | Evidência |
|---|---|
| Model/banco | Normalização e limites do título, constraint mesmo em bulk write, conflito otimista com duas instâncias |
| HTTP/autorização | Login obrigatório; leitura/escrita de outro owner retorna 404; owner/estado enviados pelo cliente não são aceitos |
| HTML/Turbo | Redirect 303, stream preserva wrapper com update, 422 HTML contém frame/erro/valor original |
| Job | Argumentos explícitos, repetição local sem incrementar duas vezes, escopo por owner e registro removido |
| Navegador | Duas criações e validação inválida preservam frame, input e Stimulus; marcador no documento comprova ausência de reload completo |

System test usa navegador real, não rack-test. Não contar testes HTTP como substituto de JS. Modo fast informa explicitamente exclusão do navegador.

## Limites

- Isolamento demonstrado é por owner (usuário), não uma implementação completa de organizações/tenants, roles ou autorização de broadcasts.
- Adapter de jobs em teste é Active Job test adapter. Não comprova operação de Solid Queue, retries distribuídos, duas execuções realmente simultâneas, outbox ou pagamentos.
- SQLite não comprova locks/SQL específicos de PostgreSQL. Migrations de sandbox não testam upgrade de dados de produção.
- App deliberadamente omite Active Storage, deploy, lint e scanners. Seguir `security-quality.md`, `data-jobs.md` e `vps.md` para esses aspectos. Gate reporta ferramentas ausentes como NÃO EXECUTADO.
- Código em `assets/example/` é fonte executável. Trechos em `hotwire.md` explicam decisões e precisam permanecer coerentes; após alterar ambos, repetir testes. Não afirmar que o script compila snippets Markdown automaticamente.

## Testar gate e avaliar agente

```bash
python3 rails8-hotwire-agent/scripts/test_check.py
```

Esses testes usam stubs isolados para verificar zero testes, todos ignorados, falhas de runner, ambientes proibidos, seleção RSpec/Minitest e autorização explícita de CI. Não executam Rails nem comprovam comportamento de um runner customizado.

Para avaliar ativação/instruções do agente, usar `evals/scenarios.md`, relativo à raiz da skill. Registrar separadamente comportamento do agente e resultados do exemplo.

## Diagnóstico

- Destino existente: selecionar novo diretório; não apagar trabalho para repetir geração. Para repetir no sandbox já criado, executar gate a partir da raiz dele, em ambiente test.
- Zero testes/resumo desconhecido: corrigir filtros/runner e fornecer resumo reconhecível ou adapter auditado; não remover gate.
- Turbo falha na segunda submissão: verificar se partial substituiu wrapper do frame; manter `update` ou wrapper completo.
- Browser ausente: registrar system tests como NÃO EXECUTADO; não converter driver para rack-test para obter verde.
- Erro de gems/Ruby: verificar versões fixadas, lockfile, acesso ao registry e plataforma antes de atualizar dependências.

## Fontes

- [Rails Authentication](https://guides.rubyonrails.org/security.html#authentication).
- [Rails System Tests](https://guides.rubyonrails.org/testing.html#system-testing).
- [Turbo Streams](https://turbo.hotwired.dev/reference/streams).
- [Turbo Forms](https://turbo.hotwired.dev/handbook/drive#redirecting-after-a-form-submission).
