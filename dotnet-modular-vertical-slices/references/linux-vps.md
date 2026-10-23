# Operação segura em VPS Linux

## Princípios

- Deploy previsível e reversível: compilar/testar no CI e promover imagem versionada; evitar builds na VPS pequena.
- Começar com contêiner da API + proxy HTTPS + PostgreSQL (preferir banco isolado quando houver recursos) + worker somente se necessário.
- Docker Compose em servidor único é aceitável; separar componentes quando os requisitos operacionais justificarem.
- Dockerfile multi-stage, runtime .NET compatível, execução com usuário sem privilégios e imagem base atualizada.
- Secrets por mecanismo de secrets ou arquivos com permissões restritas (não commitar `.env` e chaves).
- PostgreSQL sem porta pública, TLS no proxy, firewall, atualizações de segurança, retenção de logs e monitoração.
- Health probes: `liveness` para processo, `readiness` para disponibilidade da aplicação; evitar tornar liveness dependente de serviços externos instáveis.
- Definir limites de memória/CPU conforme VPS e fazer capacity planning a partir de métricas reais.
- Backups externos e testes periódicos de restauração. Backup de volume não é equivalente a backup transacional do PostgreSQL.
- Migrar schema em etapa controlada com estratégia expand/contract para evitar romper versão anterior. Rollback da imagem não reverte o banco.

## Workflow de publicação por agente

1. Auditar versões SDK/runtime, banco, env, portas, volumes e containers atuais (somente leitura).
2. Gerar artefatos de Docker/Compose sem incluir valores sensíveis.
3. Validar sintaxe e executar testes em staging/CI; testar startup, migrations, disponibilidade e restauração.
4. Solicitar aprovação explícita para deploy e migrations em produção. Não executar tarefas destrutivas antecipadamente.
5. Após aprovação, implantar imagem imutável, verificar logs e saúde, registrar versão e rollback.

## Comandos seguros de inspeção (em ambiente autorizado)

```bash
docker compose config
docker compose ps
docker compose logs --tail=100 api
```

`docker compose down -v`, `docker system prune`, `dotnet ef database update` e scripts de migração destrutiva **não** devem fazer parte de uma rotina automática de diagnóstico.
