# Checklist de revisão — Rails 8 + Hotwire

- [ ] História/requisito e critério de aceite claros.
- [ ] Solução favorece APIs nativas do Rails; novas gems justificadas.
- [ ] Responsabilidades de controller, model, job e view bem separadas.
- [ ] Autenticação e autorização verificadas com teste negativo (incluindo multi-tenant).
- [ ] Migrations compatíveis, índices, constraints e rollback avaliados.
- [ ] Sem SQL inseguro, `html_safe` não auditado, segredos ou logs sensíveis.
- [ ] Turbo Frames/Streams com targets/IDs corretos e fallback apropriado.
- [ ] Stimulus apenas para estado/efeitos locais; lifecycle/cleanup considerados.
- [ ] Jobs idempotentes, retries e transação/commit revisados.
- [ ] Testes de comportamento e de regressão executados; system tests nos fluxos críticos.
- [ ] Contagem de testes registrada; zero testes ou todos ignorados não conta como aprovação.
- [ ] Form Turbo preserva frame após duas submissões; validação inválida mantém erros/campos.
- [ ] Zeitwerk, lint, Brakeman e pipeline executados ou impedimento registrado.
- [ ] Sem alterações de infraestrutura ou deploy fora do escopo.
- [ ] Descrição final menciona riscos, configuração, migrações e verificações reais.
