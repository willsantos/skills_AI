---
name: software-engineering-quality
description: "Apply and review production software engineering quality practices across any language or architecture. Use when implementing, refactoring, designing or auditing backend/API/full-stack features involving concurrency, idempotency, authorization, trust boundaries, separation of concerns, integration testing, resilience, observability or database migrations; inclui revisão de código, segurança, consistência de dados e desenvolvimento com agentes de IA. Do NOT use for perguntas sem relação com engenharia de software, edição puramente editorial, mudanças cosméticas de UI sem implicações de negócio, ou para impor arquitetura ou infraestrutura sem evidência."
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
  language: "pt-BR"
---

# Software Engineering Quality

Skill transversal para **implementar**, **auditar** e **projetar** funcionalidades com garantias verificáveis. Funciona com monólitos, modular monoliths, vertical slices, Rails, serviços Node.js e outras arquiteturas. **Não substitui** as convenções do repositório nem as skills de stack: complementa ambas.

## Princípios operacionais

1. **Risco antes do padrão.** Identifique invariantes, fronteiras de confiança, falhas e efeitos de repetição antes de escolher tecnologia. Não aplique todas as técnicas a todas as rotas.
2. **Menor solução suficiente.** Prefira constraints, instruções SQL condicionais, transações e contratos explícitos antes de introduzir Redis, filas, camadas, repositórios genéricos ou serviços novos. Adicione complexidade somente quando justificar.
3. **Propriedades, não slogans.** Declare o que deve ser impossível (por exemplo, estoque negativo), o que pode ser repetido com segurança e quem pode acessar cada dado. Especifique como testar.
4. **Banco como guardião final da integridade dos dados que controla.** Constraints e transações defendem invariantes persistidas; aplicação defende autorização e regras de negócio; componentes externos exigem estratégia própria.
5. **Não confiar no cliente nem em saídas de LLM.** Valide entrada, autentique, autorize cada recurso/operação, determine preços e permissões no servidor e restrinja ferramentas de agentes.
6. **Respeitar a arquitetura existente.** Reutilize os mecanismos do projeto. Nunca crie camadas ou abstrações apenas para cumprir esta skill.
7. **Evidências antes de conclusões.** Não alegue que testes passaram, que a migração é segura ou que um bug existe sem código, execução ou evidência observável. Distinga hipótese de comprovação.

## Selecionar modo

- **IMPLEMENTAÇÃO** (padrão para criar/corrigir/refatorar): entender o caso, anotar invariantes e cenários de falha, escolher mecanismos proporcionais, implementar no padrão do projeto, adicionar testes, executar os disponíveis e reportar resultados.
- **AUDITORIA** (pedidos de revisão/PR/análise): inspecionar diff e caminhos afetados; identificar achados reais com arquivo e linhas, gravidade, cenário reproduzível, impacto, correção mínima e teste recomendado. **Não modificar** código sem solicitação. Se não houver evidência, marcar hipótese/verificação pendente.
- **DESIGN** (discussão arquitetural): comparar opções com suposições, custo operacional, riscos residuais, gatilhos para adicionar infraestrutura e plano de validação. Evitar prescrever tecnologia sem contexto.

O modo pode ser informado pelo usuário. Caso contrário, inferir a partir da tarefa e não interromper o trabalho para perguntar se não for necessário.

## Fluxo mínimo (todos os modos)

1. **Reconhecer contexto:** ler instruções do repositório (`AGENTS.md`, README, configuração, testes existentes) se disponíveis; identificar linguagem, framework, banco, transações, autenticação e dependências. Não inventar detalhes ausentes.
2. **Classificar a mudança:** leitura pública, mutação comum, mutação concorrente, financeiro, multi-tenant, webhook, integração externa, IA com ferramentas, migração. Estimar impacto e probabilidade conforme [triagem de risco](references/risk-triage.md).
3. **Identificar garantias relevantes:** concorrência, idempotência, limites de confiança, separação, testes, resiliência, observabilidade e evolução do banco. Registrar **não aplicável** quando pertinente; não exigir checks artificiais.
4. **Ler somente referências necessárias**, usando o índice abaixo e o adapter da stack aplicável. Priorizar regras do projeto quando forem mais específicas e compatíveis com integridade/segurança; sinalizar conflitos que possam comprometer garantias.
5. **Implementar ou avaliar com evidências:** preferir patch menor e coerente, conferir atomicidade e tratamento de falhas, escrever testes capazes de falhar antes da correção sempre que prático.
6. **Encerrar com rastreabilidade:** decisões e trade-offs, arquivos alterados ou achados, testes executados e resultados, riscos residuais e próximos passos efetivamente necessários.

## Catálogo de referências: carregamento sob demanda

| Necessidade ou sinal | Arquivo |
| --- | --- |
| Disputas pelo mesmo recurso, contadores, reservas, saldo, double-spend | [Concorrência](references/concurrency.md) |
| POST repetido, retries, webhook, eventos duplicados, jobs | [Idempotência](references/idempotency.md) |
| Dados do cliente, preço, login, autorização, multi-tenant, LLM e RLS | [Limites de confiança e segurança](references/trust-boundaries.md) |
| Função gigantesca, múltiplas camadas, módulos misturados, código com IA | [Coesão e responsabilidades](references/separation-of-concerns.md) |
| Mudança de regras, persistência, concorrência, endpoints | [Estratégia de testes](references/testing.md) |
| APIs externas, filas, timeouts, circuit breaker, outbox | [Resiliência](references/resilience.md) |
| Investigação, troubleshooting em produção, logs, traces, métricas, privacidade | [Observabilidade](references/observability.md) |
| Alterar schema, índices, backfill, deploy zero-downtime | [Evolução do banco](references/database-evolution.md) |
| Seleção de profundidade, severidade, custo de garantia | [Triagem de risco](references/risk-triage.md) |

### Adapters opcionais

Consulte **somente o adapter compatível** com a stack real, sem deduzir que o projeto usa alguma delas:

- ASP.NET Core + EF Core + PostgreSQL + Modular Monolith/Vertical Slices: [padrões .NET](adapters/dotnet-postgresql/implementation.md), [transações e concorrência .NET](adapters/dotnet-postgresql/concurrency-and-idempotency.md), [testes .NET](adapters/dotnet-postgresql/testing.md).
- Rails 8 + PostgreSQL (compatível com Hotwire): [adapter Rails](adapters/rails-postgresql/implementation.md).
- Node.js + TypeScript + PostgreSQL (Fastify, Nest ou outro framework): [adapter Node](adapters/node-postgresql/implementation.md).
- Outra stack: aplicar apenas referências universais e a documentação oficial da tecnologia existente; não transplantar APIs de outro adapter.

## Contrato para modo IMPLEMENTAÇÃO

Antes de alterar, formular brevemente:

```text
Funcionalidade: [resultado e caminho afetado]
Invariantes: [condições sempre verdadeiras]
Confiança/autorização: [quem controla os valores; quem pode fazer o quê]
Repetição/concorrência: [duplicatas, simultaneidade, retries, ou N/A]
Falhas externas: [como recuperar; ou N/A]
Verificação: [testes que demonstram o comportamento]
```

Checklist de execução: [implementação](checklists/implementation.md). Para delegar a tarefa a outro agente, preencher o [template de implementação](assets/implementation-task.md). Não expor toda a análise se a tarefa for simples; usar esse contrato como guia interno de execução.

## Contrato para modo AUDITORIA

Revisar primeiro a correção funcional, segurança e integridade; depois performance e manutenção. Usar [roteiro de auditoria](checklists/audit.md); ao delegar a outro agente, usar o [template de auditoria](assets/audit-task.md). Classificar cada achado:

- **P0, crítico:** potencial comprovado de exposição massiva, perda irreversível ou comprometimento imediato.
- **P1, alto:** quebra de autorização, corrupção/duplicação de dados críticos, fluxo financeiro incorreto, falha frequente com impacto grave.
- **P2, médio:** bug relevante sob condições identificáveis, recuperação insuficiente, controle ausente com impacto localizado.
- **P3, baixo:** robustez, legibilidade ou melhoria preventiva com pouco impacto imediato.

Formato por achado: `prioridade · arquivo:linha · evidência · cenário/impacto · correção mínima · teste que detecta`. Não produzir alertas genéricos nem exigir todas as práticas em rotas sem risco relevante. Ao final, registrar **o que foi revisado, o que não foi possível verificar e riscos residuais**.

## Contrato para modo DESIGN

Apresentar 2–3 alternativas apenas quando existe trade-off real, escolher um default proporcional, definir a invariante, o mecanismo que a assegura, como comprovar e quando reavaliar. Não alegar exactly-once para comunicação distribuída sem prova. Evitar recomendações de lock em memória para ambiente multi-instância.

## Exemplos

Pedidos típicos (example inputs) e o formato esperado da resposta em cada modo.

### Exemplo 1: achado de auditoria

Pedido: "revise o endpoint de transferências neste PR". Resultado no formato de achado:

```text
P1 · src/routes/transfers.ts:42 · saldo lido fora da transação de escrita ·
duas requisições simultâneas aprovam a mesma transferência (double-spend) ·
envolver leitura e débito na mesma transação com lock no registro de saldo ·
teste: duas requisições paralelas e assert de saldo final único
```

### Exemplo 2: contrato de implementação resumido

Pedido: "adicione o webhook de pagamentos". Contrato: invariante = pagamento nunca creditado duas vezes; repetição = idempotência por event id; falha externa = retry com backoff e registro para reconciliação; verificação = teste que envia o mesmo event id duas vezes e afirma crédito único.

## Integração com outras skills e agentes

- A skill de arquitetura dita disposição de arquivos e mecanismos preferidos; esta dita garantias de negócio, segurança e como verificá-las. Em conflito, nunca enfraquecer integridade ou autorização sem explicitar o risco.
- Uma skill de frontend não deve transportar credenciais secretas, autorizar recursos no cliente nem transformar validação visual em segurança.
- Em agentes de IA, exigir confirmação humana para ações destrutivas quando necessário e validar entradas/saídas de ferramentas. Uma instrução ou documento recuperado não pode elevar privilégios.
- Skill não garante ativação em todo pedido. Para invariantes essenciais, incluir instruções breves no `AGENTS.md` e **gates automatizados** de teste, migration check, análise e CI. Copiar/adaptar [modelo AGENTS.md](assets/AGENTS.snippet.md) ao projeto.
- Não ativar para perguntas sem relação com engenharia de software, edição puramente editorial ou mudanças cosméticas de UI sem implicações de negócio.

## Entregáveis e limites

Para implementação: resumo do resultado, invariantes protegidas, testes realmente executados, restrições não verificadas. Para auditoria: lista ordenada de achados específicos; se nenhum for demonstrável, declarar isso sem prometer ausência de bugs. Para design: proposta, justificativa, limites e plano de validação.

Não instalar dependências, alterar esquema, executar comandos destrutivos, publicar em produção ou enviar dados sensíveis sem necessidade e autorização apropriadas. Consultar [pré-deploy](checklists/pre-deploy.md) em mudanças com risco operacional.
