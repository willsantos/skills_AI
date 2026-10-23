# Avaliação de ativação e comportamento

Usar ao alterar descrição/instruções ou avaliar nova versão/modelo. Registrar prompt/contexto, modelo, ativação esperada/observada, arquivos, comandos e evidências; marcar PASS, FAIL ou NÃO EXECUTADO. Dependência ausente não é aprovação. Testes do sandbox e do gate não comprovam estes cenários de agente.

## Deve ativar, com contexto Rails 8

1. **CRUD:** "Adicione tarefas privadas por usuário". Esperado: Rails convencional, escopo no servidor, strong parameters e testes negativos; sem repository/service obrigatório.
2. **Turbo:** "Formulário funciona uma vez e depois para". Esperado: verificar wrapper/IDs/targets, distinguir update e replace; duas submissões e falha de validação em browser.
3. **Fallback:** "Corrija submit inválido em Turbo Frame". Esperado: 422 com frame esperado, erros e input; 303 em redirect após escrita.
4. **Autorização:** "Usuário acessa tarefa de outra conta pelo ID". Esperado: bloquear leitura/escrita, testar vazamento e mass assignment de owner/tenant.
5. **Anexos:** "Proteja documentos privados no Active Storage". Esperado: reconhecer rotas públicas padrão, autorização direta de download e signed URL como posse do link.
6. **Concorrência:** "Dois usuários editam a mesma fatura". Esperado: política de versão/lock e tratamento explícito de conflito; testar duas instâncias.
7. **Jobs:** "Evite cobrança duplicada após timeout". Esperado: chave persistida, suporte do gateway e reconciliação; não basta booleano local.
8. **Fila:** "Salve pedido e garanta publicação com Solid Queue em outro banco". Esperado: reconhecer janela commit/enqueue, avaliar outbox e reentrega; não prometer exactly-once.
9. **Legado:** "Adicione feature no app que já usa RSpec e Sidekiq". Esperado: preservar stack válida, usar suíte existente e não impor Minitest/Solid Queue.
10. **Verificação:** "CI retornou zero mas rodou zero testes". Esperado: não aprovar; corrigir descoberta/filtros. Se bin/ci existir, revisar antes de executar.
11. **Produção:** "Publique e migre o banco". Esperado: inventário, plano/backup e autorização explícita antes de ação mutável; rollback de imagem não desfaz schema.

## Não deve ativar

1. "Explique blocks em Ruby" sem contexto de aplicação Rails.
2. "Implemente API em ASP.NET Core".
3. "Crie SPA React independente de backend Rails".
4. "Configure firewall de uma VPS" sem contexto Rails.

## Critério

PASS exige todos os resultados esperados do cenário e relato honesto do que não foi executado. Não inventar percentuais de ativação a partir de leitura da descrição; registrar número real de cenários avaliados e preservar falhas observadas.
