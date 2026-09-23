---
name: software-documentation
description: Cria, atualiza, organiza, versiona e valida documentação de software seguindo o padrão Docusaurus do repositório. Use when creating or updating technical documentation, architecture, APIs, features, deployment, troubleshooting, ADRs, diagrams, and releases in Docusaurus monorepos. Do NOT use for code comments, inline JSDoc, or writing code logic.
metadata:
  author: "willsantos"
  github: "https://github.com/willsantos"
  version: "1.0.0"
---

# Software Documentation Skill

Esta skill aplica o padrão de documentação Docusaurus do projeto.

O objetivo é manter documentação:

- consistente entre produtos;
- próxima do código;
- independente da stack;
- versionada por produto;
- amigável para agentes;
- publicável como site estático;
- visualmente preparada para um design system compartilhado.

## 1. Descoberta obrigatória

Antes de alterar documentação:

1. localize `docs-manifest.yml` na raiz do repositório;
2. localize o app Docusaurus, normalmente `apps/docs`;
3. identifique o produto ou área afetada pela tarefa;
4. leia a documentação existente relacionada;
5. inspecione o código relevante quando a documentação depender do comportamento real;
6. preserve convenções existentes que não contradigam esta skill.

O padrão Docusaurus da Oroborus vive no Oroborus Knowledge (RAG): pattern `docs.docusaurus-site` no checkout do monorepo OroRag. Leia seu README e artefatos antes de mudanças estruturais — identidade visual (tokens Oroborus em Infima), config canônica e o standard de monorepo (`docusaurus/monorepo-standard.md`) estão lá.

Se `docs-manifest.yml` não existir, não invente a topologia do sistema. Inspecione o monorepo e use a estrutura existente como fonte primária.

## 2. Mapeamento padrão

Por convenção:

```text
apps/docs
```

é o engine/site Docusaurus.

Documentação transversal:

```text
docs/platform
```

Documentação corrente de produto:

```text
apps/<produto>/docs
```

Exemplos:

```text
apps/web/docs
apps/desktop/docs
apps/cli/docs
```

Não assuma que todo diretório em `apps/` deve possuir documentação ou versionamento próprio.

## 3. Escolha do destino

Use documentação de plataforma quando a mudança tratar de:

- arquitetura global;
- domínio compartilhado;
- integração entre aplicações;
- decisões arquiteturais;
- segurança transversal;
- observabilidade;
- CI/CD;
- convenções comuns.

Use documentação do produto quando a mudança tratar de:

- comportamento daquele app;
- configuração;
- comandos;
- interface;
- API específica;
- deploy específico;
- troubleshooting específico;
- requisitos específicos.

Quando necessário, atualize plataforma e produto, evitando duplicação.

## 4. Política de escrita

Preferir Markdown (`.md`).

Usar MDX (`.mdx`) somente quando um componente aprovado for necessário.

Escrever para explicar o software, não para narrar o código.

Priorizar:

1. propósito;
2. comportamento;
3. contratos;
4. configuração;
5. exemplos úteis;
6. limitações;
7. troubleshooting.

Evitar:

- repetir nomes de métodos sem explicar comportamento;
- documentar implementação trivial;
- texto promocional;
- informações inferidas sem confirmação;
- duplicar conteúdo já existente;
- criar páginas vazias;
- criar categorias artificiais só para seguir uma árvore padrão.

## 5. Estrutura

Antes de criar um novo arquivo:

1. procure documento existente que possa ser atualizado;
2. verifique a hierarquia atual;
3. preserve URLs estáveis;
4. use a pasta conceitualmente mais próxima.

Estrutura típica de produto:

```text
docs/
├── index.md
├── getting-started/
├── concepts/
├── architecture/
├── features/
├── configuration/
├── reference/
├── deployment/
└── troubleshooting/
```

Adapte ao produto. Não crie todas as pastas automaticamente.

## 6. Frontmatter

Usar apenas metadata necessária.

Padrão mínimo:

```yaml
---
title: Título
description: Descrição objetiva da página.
---
```

Se a página publicada precisar manter uma URL estável, considere `slug`.

Não invente campos de UI ainda não definidos pelo padrão do projeto.

## 7. Diagramas

Use Mermaid quando um diagrama melhorar a compreensão.

Preferir sintaxe conservadora:

```text
graph TD
graph LR
sequenceDiagram
classDiagram
stateDiagram-v2
erDiagram
```

Para fluxos, preferir `graph` em vez de `flowchart`.

Evitar:

- HTML nos nós;
- Font Awesome;
- sintaxe experimental;
- `---->`;
- conexões diretamente para/de `subgraph` quando evitáveis;
- recursos dependentes de um único renderer.

O diagrama deve permanecer compatível, sempre que possível, com Docusaurus, GitHub, VS Code e Azure DevOps.

## 8. Versionamento

A documentação é versionada por produto, não pelo monorepo.

Cada produto pode ter versão própria.

Exemplo válido:

```text
web      4.2
desktop  2.7
cli      1.9
```

Não sincronize versões artificialmente.

A documentação corrente é editável.

Snapshots históricos são imutáveis por padrão.

Nunca editar manualmente:

```text
*_versioned_docs/
*_versioned_sidebars/
*_versions.json
```

Exceção: uma tarefa solicitar explicitamente correção/backport de documentação histórica.

## 9. Criando uma versão

Só criar snapshot quando a tarefa estiver relacionada a release/versionamento.

Antes:

1. confirme o produto;
2. confirme a versão;
3. confirme a estratégia em `docs-manifest.yml`;
4. garanta que a documentação corrente corresponde ao release;
5. execute o build;
6. corrija erros.

Para uma instância `web`:

```bash
pnpm docusaurus docs:version:web 4.2
```

ou o comando equivalente do package manager utilizado no projeto.

Não editar `web_versions.json` manualmente.

Após o comando, validar o build novamente.

## 10. Relação código -> documentação

Ao analisar uma mudança, verificar se ela altera:

- comportamento público;
- API;
- comandos;
- parâmetros;
- configuração;
- variáveis de ambiente;
- formatos de arquivo/dados;
- arquitetura;
- integrações;
- autenticação;
- autorização;
- deploy;
- operação;
- compatibilidade;
- troubleshooting.

Se não houver impacto documentável, não force uma alteração de docs.

## 11. UI

A camada de UI pertence ao app Docusaurus.

Por padrão:

```text
apps/docs/src/css
apps/docs/src/components
apps/docs/src/theme
```

Regras:

- não criar CSS inline em documentos;
- não criar estilos específicos por produto sem padrão aprovado;
- reutilizar componentes existentes;
- não duplicar componentes;
- preferir Markdown puro;
- usar componentes MDX somente quando já forem parte do padrão;
- preservar separação entre conteúdo e apresentação.

Esta seção deve ser expandida quando o design system de documentação for definido.

## 12. Docusaurus

Não substituir o engine.

Quando precisar alterar configuração:

1. identifique a versão instalada;
2. consulte padrões existentes no repositório;
3. mantenha todos os pacotes `@docusaurus/*` na mesma versão;
4. preserve `@docusaurus/preset-classic`, salvo decisão explícita;
5. preserve geração estática;
6. preserve compatibilidade com GitHub Pages.

No bootstrap, usar TypeScript.

## 13. Validação

Depois de alterar documentação, quando o ambiente permitir:

1. executar o build do Docusaurus;
2. corrigir links quebrados;
3. validar imports MDX;
4. validar Mermaid;
5. validar assets;
6. verificar se documentos movidos mantiveram URLs quando necessário.

O projeto deve configurar:

```ts
onBrokenLinks: 'throw'
```

O comando exato deve respeitar o package manager do repositório.

Exemplos:

```bash
pnpm build
npm run build
yarn build
```

Executar no app Docusaurus ou pelo comando de workspace definido pelo monorepo.

## 14. Bootstrap de documentação

Quando a tarefa for iniciar documentação Docusaurus em um repositório que ainda não possui o padrão:

1. inspecione o monorepo;
2. preserve o package manager existente;
3. crie `apps/docs` com Docusaurus Classic + TypeScript;
4. desabilite o blog;
5. remova conteúdo de demonstração;
6. crie `docs-manifest.yml`;
7. crie `docs/platform` somente se houver conteúdo transversal;
8. identifique quais produtos realmente precisam de documentação versionada;
9. crie uma instância de docs por produto com ciclo independente;
10. mantenha documentação corrente próxima ao produto;
11. configure sidebar autogerada;
12. habilite Mermaid;
13. configure links quebrados como erro;
14. prepare `static/.nojekyll`;
15. execute build;
16. não invente uma identidade visual avançada ainda.

## 15. Resultado esperado

Ao concluir uma tarefa de documentação, informe de forma objetiva:

- documentos criados;
- documentos atualizados;
- produto/área afetada;
- se houve mudança estrutural;
- se houve criação de versão;
- validações executadas;
- erros ou limitações ainda existentes.

Não gerar um relatório longo quando poucas alterações forem realizadas.

## 16. Referência

Para bootstrap e decisões estruturais, consulte o Oroborus Knowledge (checkout do monorepo OroRag):

```text
knowledge/patterns/docusaurus-site/README.md                 guideline + identidade visual
knowledge/patterns/docusaurus-site/docusaurus/monorepo-standard.md   topologia monorepo multi-produto
```

O pattern é a fonte canônica (versionado, validado e recuperável via MCP `knowledge_search`/`artifact_get`); esta skill deve ser atualizada junto com ele quando as convenções estruturais mudarem.
