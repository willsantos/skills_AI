# Exemplos de decisão

| Situação | Preferir | Evitar |
| --- | --- | --- |
| Formatar uma data em um único ponto | Recurso nativo com opções explícitas | Dependência nova e wrapper genérico |
| Duas rotas precisam da mesma regra de autorização | Reusar o mecanismo existente ou extrair regra compartilhada | Copiar a condição ou criar framework próprio |
| Um caso de erro vindo de API externa | Validar na fronteira e tratar falha real | Assumir retorno perfeito para economizar linhas |
| Uma operação única de poucas linhas | Código local e legível | Interface, factory e serviço só para acomodá-la |
| Código semelhante com diferenças de domínio | Manter separado quando a abstração obscurece regras | Generalizar apenas porque os trechos parecem iguais |
| Alteração de esquema com risco de perda | Migração segura e verificação adequada | Encolher o diff à custa de dados |

Uma solução com mais linhas pode ser melhor quando explicita estados, melhora diagnóstico ou evita acoplamento. Uma linha a menos não justifica reduzir segurança, acessibilidade ou clareza.
