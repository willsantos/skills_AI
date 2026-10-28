# Template de tarefa para agente: auditoria

Auditar [diff/branch/feature] sem alterar arquivos. Priorizar integridade, autorização, idempotência e concorrência. Ler `AGENTS.md` e convenções antes. Usar `software-engineering-quality` com adapter da stack real.

Para cada achado, informar:

```text
[P0-P3] Título
Arquivo e linha: ...
Evidência: trecho/comportamento demonstrável
Cenário que desencadeia: ...
Impacto: ...
Correção mínima: ...
Teste reproduzível: ...
```

Separar achados comprovados de riscos a investigar. Não presumir que algo ausente no diff inexiste no repositório. Encerrar com arquivos examinados, verificações executadas, pontos não examinados e riscos residuais.
