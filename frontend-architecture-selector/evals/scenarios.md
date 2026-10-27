# Cenários de avaliação do seletor

1. **ERP autenticado, 2 GB VPS, CRUDs:** esperar análise séria Razor Pages vs SPA estática; não recomendar SSR Node por padrão.
2. **Dashboard com gráficos e drag-and-drop, 4 GB:** considerar Vue/Vite, React/Vite e Angular; distinguir Node no build de Node em runtime.
3. **Portal público indexável com dados atualizados:** exigir SSR/SSG/HTML server; rejeitar SPA pura sem plano.
4. **Editor dependente de biblioteca React-only:** justificar React; Next apenas se rendering exigir.
5. **Angular já em produção e nova feature:** preservar ADR/stack, não reabrir framework.
6. **Site misto marketing + app privado:** comparar híbrido vs solução única com custo operacional.
7. **Agente escolheu stack:** gerar ADR com alternativa descartada, riscos e testes, não só nome de ferramenta.
