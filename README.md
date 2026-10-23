# Oroborus Skills

Repositório de skills padronizadas para agentes de inteligência artificial (Claude Code, OpenCode, Codex, Gemini CLI, Cursor, Trae, Kiro, etc.).

---

## O que é uma Skill?

Uma skill é um pacote autocontido de instruções de procedimento, referências de domínio e ferramentas que ensinam agentes a executar tarefas complexas de forma consistente e determinística.

Skills são desenhadas prioritariamente **para LLMs e agentes**, não humanos. A documentação humana vive neste `README.md` raiz.

---

## Princípios de Arquitetura

### 1. Progressive Disclosure (Economia de Contexto)

Modelos possuem limites de contexto e sofrem com degradação quando recebem volume desnecessário de instruções. Cada skill organiza seu conteúdo em três níveis rígidos:

| Nível | Localização | Descrição | Orçamento | Momento de Carga |
| :--- | :--- | :--- | :--- | :--- |
| **L1** | **Frontmatter YAML** (`SKILL.md`) | Nome, descrição de roteamento e metadados de autoria. | ~100 palavras max | Carregado em **todas** as sessões do agente para descoberta. |
| **L2** | **Corpo principal** (`SKILL.md`) | Fluxo de trabalho, tomada de decisão e regras críticas. | < 500 linhas | Carregado apenas quando a skill é acionada pelo usuário. |
| **L3** | **Arquivos vinculados** (`references/`, `scripts/`, `assets/`) | Especificações profundas, tabelas completas, scripts de checagem. | Sob demanda | Carregado apenas quando uma condição explícita no L2 é atingida. |

### 2. Metadados e Frontmatter Obrigatórios

Cada `SKILL.md` deve iniciar estritamente com:

```yaml
---
name: nome-da-skill
description: Resumo do que faz. Use when [frases que acionam a skill]. Do NOT use for [escopo negativo / limites].
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
---
```

- **`name`**: lowercase em kebab-case idêntico ao nome do diretório.
- **`description`**:
  - Deve conter gatilhos positivos explícitos (`Use when...` ou `Usar quando...`).
  - Deve conter limites negativos explícitos (`Do NOT use for...` ou `Não usar para...`).
  - Menor que 1024 caracteres e sem caracteres `<` ou `>`.
- **`metadata`**: `author`, `github` e `version` (formato semver).

### 3. Estrutura de Diretórios Padrão

```text
nome-da-skill/
├── SKILL.md                 # Instruções executáveis centrais (L2)
├── agents/
│   └── openai.yaml          # Configuração de interface/integração do agente
├── assets/
│   └── icon.svg             # Ícone SVG 24x24
├── references/              # (Opcional L3) Documentos aprofundados
└── scripts/                 # (Opcional) Scripts determinísticos de automação/validação
```

> **Atenção:** Nunca inclua `README.md` dentro de pastas de skills individuais. Toda informação para o agente deve estar no `SKILL.md` ou em `references/`.

---

## Criando ou Padronizando uma Skill

Para agentes e desenvolvedores adicionando novas skills:

1. Consulte as diretrizes em `AGENTS.md` e a skill `skill-architect`.
2. Mantenha o `SKILL.md` conciso (menos de 500 linhas), movendo materiais extensos para `references/`.
3. Garanta que `agents/openai.yaml` e `assets/icon.svg` estejam presentes.
4. Execute o script de validação oficial:
   ```bash
   python3 .claude/skills/skill-architect/scripts/validate_skill.py <nome-da-skill>
   ```
   A skill deve passar (`PASS`) sem erros antes de ser comitada.

---

## Rails 8 + Hotwire

`rails8-hotwire-agent/` orienta Rails idiomático, Hotwire, autorização, jobs e operação com Kamal. Copie a pasta completa para o diretório de skills do cliente, por exemplo `.agents/skills/rails8-hotwire-agent/`; não copie somente `SKILL.md`.

- Adapte `assets/AGENTS.template.md` na raiz do projeto. Use `assets/PR_CHECKLIST.template.md` na revisão.
- No app Rails, execute `bash <caminho-da-skill>/scripts/check.sh fast` ou `full`. Modo `full` requer navegador. Se houver `bin/ci`, revise-o antes de autorizar modo `ci` com `CI_REVIEWED=1`.
- Para reproduzir código e testes sem alterar uma aplicação existente, siga `rails8-hotwire-agent/references/testing-example.md`. Sandbox usa versões fixadas para teste, não recomenda patches para produção.
- Skill não substitui testes, revisão de segurança nem conhecimento de domínio. Não executa deploy automaticamente.

## Licença

Distribuído sob a licença Apache 2.0. Consulte `LICENSE` para mais detalhes.
