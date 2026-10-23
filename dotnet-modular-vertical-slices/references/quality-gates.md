# Gates de qualidade para agentes

## Comandos básicos (ajustar ao repo)

```bash
dotnet --info
dotnet restore
dotnet build --no-restore -warnaserror
dotnet test --no-restore
# Opcional se configurado:
dotnet format --verify-no-changes --no-restore
```

O script `scripts/verify-dotnet.sh` executa os primeiros passos a partir da raiz do repositório, com configuração opcional. Testes dependentes de serviços externos devem usar ambiente de testes, nunca produção.

## Matriz por mudança

| Mudança | Evidência mínima |
|---|---|
| Invariante de domínio | Unit test incluindo bordas e inválidos |
| Escrita/query EF | Teste de integração com provider real para o comportamento SQL importante |
| Endpoint | HTTP success + bad request + auth/forbidden + not found conforme rota |
| Mudança de schema | Migration revisada, compatibilidade com versão anterior, backup/rollback planejados |
| Integração externa | Falha/timeout/retry, idempotência e testes com fake/contrato |
| Comunicação entre módulos | Architecture tests de dependência e contrato público |
| Correção de bug | Teste que falha antes da correção quando possível |
| Segurança | Testes de autorização, tenant isolation, validação e secrets |

## Checklist antes de concluir

- [ ] Requisitos e critérios de aceitação preservados.
- [ ] Arquivos modificados pertencem ao módulo certo.
- [ ] Domínio protege invariantes sem confiar apenas no endpoint.
- [ ] Request/Response explícitos; não expor entidade EF.
- [ ] Queries eficientes e paginadas, sem N+1 desnecessário.
- [ ] Falhas HTTP usam status coerentes/Problem Details; não vazam stacktrace/segredos.
- [ ] Authn, authz e ownership/tenant testados quando necessário.
- [ ] DbContext scoped e sem paralelismo na mesma instância.
- [ ] Sem abstrações artificiais, duplicação ou dependências novas injustificadas.
- [ ] Build, testes, analyzers e format executados quando possível.
- [ ] Alterações de contrato/OpenAPI e migration avaliadas e relatadas.
- [ ] Sem operações destrutivas ou deploy não autorizado.

## Testes arquiteturais

Com projetos separados por módulo, proibir referências fora das APIs públicas e ciclos de dependência. Em projeto único, testes por namespaces/convenções são parcialmente úteis, mas não garantem isolamento absoluto: complementar com revisão de referências, testes de comportamento e eventualmente separação de assemblies.

## Como reportar incerteza

Usar rótulos específicos no resumo de execução: `VERIFICADO` (com comando), `NÃO EXECUTADO` (com motivo), `PENDENTE` (necessita requisito ou ambiente). Não afirmar que uma feature compila porque o exemplo parece correto.
