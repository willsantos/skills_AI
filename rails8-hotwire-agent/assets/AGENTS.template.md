# AGENTS.md — Rails 8 + Hotwire

> Modelo para copiar para a RAIZ do projeto, adaptar e manter versionado. Não substitui a skill: referencia suas diretrizes gerais.

## Projeto

- Produto: [descrever]
- Ruby: [ver Gemfile/.ruby-version]
- Rails: [ver Gemfile.lock]
- Banco: [SQLite/PostgreSQL, conforme app]
- Autenticação/autorização: [método e módulos existentes]
- Jobs e cache: [adapters reais]
- Deploy: [Kamal / Compose / systemd, VPS / outros]

## Convenções obrigatórias

- Rails convencional e SSR com Hotwire (Turbo e Stimulus).
- Desenvolvimento por recursos/domínios, monólito modular pragmático.
- Usar recursos nativos antes de novos frameworks ou gems.
- Controller fino, regras nos models ou em operações específicas quando necessário.
- Sem repositories genéricos, mappers ou services para CRUD simples.
- Acesso por tenant/usuário sempre escopado e testado.
- Sem secrets no git ou no frontend.
- Não executar migrations/deploy/comandos destrutivos em produção sem aprovação.
- Seguir a skill `rails8-hotwire-agent` quando disponível.

## Verificação local

```bash
bin/rails zeitwerk:check
bin/rails test
bin/rails test:system  # se houver mudanças de UI e navegador configurado
bin/rubocop           # se presente
bin/brakeman -q       # se presente
bin/ci                # se este for o comando de CI do repositório
```

## Limites e particularidades do negócio

[Descrever domínios, recursos, permissões, invariantes, serviços externos, padrões de nomes e riscos.]

## Critérios para concluir

Entregar comportamento testado, sem regressões conhecidas, relatando os comandos de fato executados, limitações, dependências e impacto em deploy/migrations.
