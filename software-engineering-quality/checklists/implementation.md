# Checklist de implementação (use conforme risco)

**Antes da mudança**

- [ ] Identifiquei a feature, o contrato e o padrão arquitetural já adotado.
- [ ] Declarei invariantes e a fonte de autoridade de cada campo de entrada.
- [ ] Classifiquei concorrência, reenvio, privacidade, falhas externas e evolução de schema como aplicável/não aplicável.
- [ ] Selecionei a menor solução capaz de preservar as garantias, com trade-offs conhecidos.

**Durante a mudança**

- [ ] Autorização é imposta no backend em cada recurso e operação.
- [ ] Constraints e transações protegem invariantes persistidas, inclusive sob concorrência se aplicável.
- [ ] Duplicações/retries preservam efeitos de negócio quando a operação puder ser repetida.
- [ ] Chamadas externas têm limites de tempo, falhas tratadas e estratégia de recuperação quando necessárias.
- [ ] Módulos/slices respeitam fronteiras e não ganharam camadas fictícias.
- [ ] Nenhum segredo ou campo sensível foi exposto em cliente, logs ou ferramentas de IA.

**Comprovação**

- [ ] Tests: casos felizes, inválidos e riscos reais (concorrência, replay, acesso cruzado, falha intermediária).
- [ ] Testes SQL relevantes rodaram contra o banco real com migrations.
- [ ] Comandos e resultados foram reportados sem inventar execução.
- [ ] Limitações, riscos residuais e decisões não óbvias ficaram explícitos.
