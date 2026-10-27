# Tempo real, upload e tarefas longas

- **SSE:** stream HTTP unidirecional (tokens de LLM, progresso). Definir reconexão, cancelamento com `AbortController`/unsubscribe, timeout e limites de conexões do proxy.
- **SignalR/WebSockets:** escolher somente quando o cliente envia eventos em tempo real ou múltiplos canais exigem comunicação bidirecional; proxy precisa permitir upgrade, sticky state ou backplane se houver múltiplas instâncias.
- **Jobs:** tarefas demoradas saem da request: fila + worker .NET + endpoint de consulta/status. Informar identificador seguro e status com autorização por recurso.
- **Upload:** usar streaming para arquivos grandes, limites, extensão/MIME + análise de conteúdo, autenticação, armazenar fora de diretórios públicos, URL assinada se necessário.
- **Observabilidade:** correlation ID, trace de backend, medição de latência API e provedor externo; não logar conteúdo sensível ou tokens.
- **Não prometer entrega assíncrona sem infraestrutura real**. Respostas de UI devem representar estado real das tarefas.
