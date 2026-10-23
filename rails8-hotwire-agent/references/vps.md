# Publicação Rails 8 + Hotwire em VPS Linux

## Princípios

- Priorizar **serviço web único** quando Rails renderiza o HTML e Hotwire fornece interatividade.
- Para serviço Linux próprio, preferir Dockerfile de produção gerado pelo Rails e Kamal do próprio projeto (salvo arquitetura já padronizada com Compose/systemd).
- Toda decisão operacional deve considerar tamanho da VPS, outros serviços existentes, persistência de arquivos, capacidade de backup, domínio e rotina de manutenção.
- Nunca fazer deploy, migrations, `kamal setup`, alterar firewall ou apagar volumes sem autorização explícita.

## Inventário antes do deploy

Obter e verificar: distro/versão Linux, CPU/RAM/disco, DNS/domínio, SSH, usuário de deploy, Docker, porta 80/443, banco local ou externo, storage local ou remoto, workers, redis (se houver), segredo de produção, configuração TLS, backup e logs.

Não presumir que uma VPS tem capacidade para Rails, banco, fila e processamentos pesados simultâneos. Testar memória sob carga e ajustar Puma `WEB_CONCURRENCY`, `RAILS_MAX_THREADS`, pool de DB e workers.

## Kamal

1. Confirmar `Gemfile.lock`, versão do Kamal, `Dockerfile` e `config/deploy.yml` **existentes**.
2. Usar imagem versionada, `service` e `image` definidos, `servers` com acesso seguro, `proxy` com `host` e TLS configurado.
3. Guardar `RAILS_MASTER_KEY`, `DATABASE_URL`, credenciais de registry e demais secrets fora do git, conforme mecanismo efetivo de Kamal.
4. Não expor PostgreSQL e componentes de fila publicamente; preferir rede privada/túnel SSH conforme arquitetura.
5. Configurar rota de health check que só retorne saudável quando aplicação está em estado apto a servir; verificar dependências relevantes sem torná-la excessivamente cara.
6. Backup offsite **antes** do primeiro deploy e antes de migração de risco; testar restore.
7. Runbooks de deploy, log, rollback, migração e restauração devem ser documentados e ensaiados em staging sempre que possível.

**Exemplo deliberadamente incompleto** (`config/deploy.yml`, não usar sem adaptar versão, domínio, secrets e infraestrutura):

```yaml
service: example
image: registry.example.com/example
servers:
  web:
    - 203.0.113.10
proxy:
  host: app.example.com
  ssl: true
  app_port: 3000
# registry, env, secrets, banco, volumes e builder dependem do ambiente.
```

Esse bloco **não** é uma configuração pronta para produção. Endereço e domínio são exemplos reservados, não recursos reais.

## Operação e disponibilidade

- Build em CI quando viável para não competir com Rails/DB pela RAM da VPS.
- Escalonamento vertical é o primeiro passo em muitos SaaS pequenos. Só dividir serviços por razão operacional medida.
- Usar health check/rotatividade de imagens e checar deploy por logs e smoke test.
- Deploy de aplicação com troca de imagem não desfaz migração incompatível. Usar expand/contract e compatibilidade com versão anterior.
- Backups incluem: banco primário, storage local/Active Storage, dados da fila persistentes quando críticos, configuração e recuperação de secrets (sem publicá-los).
- Verificar política de retenção, restore, espaço em disco, crescimento de logs/volumes e certificados HTTPS.
- Se Solid Queue rodar no mesmo host/processo, estimar interferência de tarefas em uso de RAM, threads e requests; isolar worker se necessário.
- Configurar telemetria proporcional ao tamanho da VPS: logs estruturados, uptime, erro, disco/memória, duração de request/job e atraso de fila.
- Tratar segurança SSH, pacotes do sistema, Docker, firewall e credenciais como parte do ciclo de manutenção.

## Critérios antes de recomendar outro serviço

**Redis/Sidekiq:** requerer problema real que Solid Queue não atende.
**PostgreSQL externo:** avaliar custo, backup, recuperação e pressão de RAM da VPS.
**Object storage externo:** adequado quando uploads precisam sobreviver a reconstruções do servidor e facilitar recuperação.
**React/Next.js:** adicionar apenas se houver requisitos de UI cuja implementação em Hotwire/Stimulus tenha custo ou limitação comprovada.
**Docker Compose/systemd:** preservar se já são solução operacional madura; Kamal não é obrigação universal.

Fontes oficiais: https://kamal-deploy.org/docs/ ; https://kamal-deploy.org/docs/configuration/ ; https://kamal-deploy.org/docs/configuration/proxy/ ; https://guides.rubyonrails.org/getting_started.html
