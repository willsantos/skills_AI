# rails8-hotwire-agent

Skill de agentes em português para Rails 8 + Turbo + Stimulus, orientada à construção de um monólito modular pragmático, com convenções Rails nativas, testes e publicação em VPS Linux.

## Instalação

Copie a pasta inteira `rails8-hotwire-agent/` para o diretório de skills aceito por seu agente. Exemplos comuns:

- `./.agents/skills/rails8-hotwire-agent/` no repositório, quando o cliente suporta Agent Skills no projeto.
- Um diretório de skills específico do cliente (consultar documentação do Codex, Claude Code, OpenCode ou ambiente utilizado).

**Não copie apenas o `SKILL.md`**: ele referencia arquivos em `references/` e um script em `scripts/`.

Copie `assets/AGENTS.template.md` para `AGENTS.md` na raiz do projeto e adapte versões, comandos, domínios e autorização reais. Não copie configurações fictícias literalmente para produção.

## Estrutura

```text
rails8-hotwire-agent/
  SKILL.md
  references/
    architecture.md
    hotwire.md
    data-jobs.md
    security-quality.md
    vps.md
    agent-workflow.md
  scripts/
    check.sh
  assets/
    AGENTS.template.md
    PR_CHECKLIST.template.md
```

## Verificação rápida

Dentro da raiz de um Rails que tenha esta skill copiada:

```bash
.agents/skills/rails8-hotwire-agent/scripts/check.sh fast
.agents/skills/rails8-hotwire-agent/scripts/check.sh full
```

`full` inclui testes de sistema e requer ambiente de browser apropriado. O script não inicia deploys, não instala gems nem altera produção.

## Escopo

A skill orienta decisões e verificações, mas **não substitui testes, revisão de segurança e conhecimento do domínio**. Seguir o repositório e a versão real das gems. Agentes não devem declarar testes ou deploy como bem-sucedidos sem execução.

## Referências usadas (consultadas em outubro de 2026)

- https://agentskills.io/specification
- https://rubyonrails.org/2026/9/24/Rails-Version-8-1-4-has-been-released
- https://guides.rubyonrails.org/getting_started.html
- https://guides.rubyonrails.org/active_job_basics.html
- https://guides.rubyonrails.org/testing.html
- https://turbo.hotwired.dev/handbook/introduction
- https://stimulus.hotwired.dev/handbook/introduction
- https://kamal-deploy.org/docs/
