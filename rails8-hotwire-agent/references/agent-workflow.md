# Playbook de execução de tarefas para agentes de programação

## 1. Mapear antes de implementar

Sem modificar código, coletar:
- Objetivo do usuário, critério de aceite observável e fluxos com falha.
- `AGENTS.md`/instruções locais, versões reais, comandos de teste e config de CI.
- Controller, model, views, partials, rotas, Stimulus, jobs e testes existentes.
- Regras de autorização, tenant, integrações externas e persistência envolvidas.

Registrar plano simples para alterações com mais de uma etapa; não pedir autorização por mudanças rotineiras de código permitidas, mas **pedir aprovação para ações irreversíveis ou de produção**.

## 2. Implementar fatia vertical pequena

Exemplo para criar assinatura:
1. Adicionar migration segura com índices/constraints, se necessária.
2. Colocar regras no model ou uma operação `Subscriptions::Activate`, se complexidade justificar.
3. Controller com `current_account`/`Current.user` e `strong_parameters`.
4. Views server-rendered, parcial `_subscription` e updates Turbo adequados.
5. Testes de estado, autorização cruzada, HTML/Turbo e erro de validação.
6. Rodar verificações relevantes e revisar SQL/performance.

Se precisar de gem: pesquisar alternativa nativa, versão do framework, compatibilidade, custo de segurança e de manutenção; documentar justificativa da dependência.

## 3. Feedback durante o trabalho

- Fazer alterações coesas em pequenos incrementos.
- Compilar/carregar e testar cedo; não deixar dezenas de arquivos sem executar testes.
- Registrar saídas reais de comandos, não apenas afirmar que 'passou'.
- Ao encontrar incerteza material em API/gem, conferir docs oficiais e lockfile.
- Se testes falharem por causa anterior, separar falha preexistente da introduzida (com evidências, sem alterar teste indevidamente).
- Se múltiplos agentes trabalharem, reservar ownership de arquivos, prevenir conflitos e passar contratos definidos antes de alterações paralelas.

## 4. Relato final obrigatório

Use este modelo compacto:

```text
Objetivo: <mudança observável>
Implementado: <funcionalidades e arquivos essenciais>
Verificado: <comandos realmente executados e resultado>
Não verificado: <limitações concretas, se houver>
Riscos / deploy: <migração, worker, variáveis, plano de reversão, se aplicável>
```

Proibir: alegar sucesso sem teste, ocultar alterações de esquema, incluir credenciais e entregar deploy executado sem autorização.

## 5. Exemplos de decisões

**Pedido**: "Adicionar pesquisa de produtos por nome".
- Implementar scope seguro no Active Record, parâmetro escopado, formulário GET server-rendered e Turbo Frame apenas se melhorar UX; criar índice se carga justificar; testar tenant e filtros.
- **Não** criar ElasticSearch, React, CQRS, SearchService e Redis por antecipação.

**Pedido**: "Gerar relatório demorado".
- Active Job + Solid Queue (se disponível), persistir status e atualizar UI via Turbo Frame por polling ou Turbo Streams autenticados conforme necessidade.
- Testar retentativas, estados intermediários, custo e prazo; evitar bloquear request web.

**Pedido**: "Migrar para VPS".
- Primeiro inventário operacional, README/runbook, backup e estratégia de secrets. Validar em staging. Exigir aprovação antes de rodar comandos mutáveis.
