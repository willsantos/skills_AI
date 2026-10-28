# Trecho opcional para AGENTS.md do projeto

## Garantias transversais de engenharia

Para implementar, alterar ou revisar código de negócio, utilizar a skill `software-engineering-quality` quando acessível. Preservar a arquitetura e as convenções da stack local; usar o adapter apenas se corresponder à tecnologia real.

Em cada funcionalidade sensível, identificar invariantes, autorização por objeto, concorrência, semântica de retry/idempotência, falhas externas e testes que demonstram as garantias. Considerar `não aplicável` quando houver justificativa. Preferir controles nativos de banco (constraints, transações, updates condicionais), sem introduzir filas/Redis/abstrações sem necessidade.

Código de agente/LLM e dados do navegador ou fontes externas são não confiáveis. Nunca confiar em preço, identidade, tenant ou papéis vindos do cliente; nunca divulgar secrets. Saídas de ferramentas devem respeitar autorização e validação do servidor.

Para PRs com mutações críticas, exigir testes de integração contra banco real e registrar comandos executados, resultados e limitações. Em revisão, apresentar achados verificáveis por `arquivo:linha`, gravidade, impacto e correção, sem editar código por iniciativa própria.

> Adaptar este trecho ao projeto. Instruções obrigatórias devem ser acompanhadas por CI/testes; uma skill pode não ser ativada automaticamente a cada tarefa.
