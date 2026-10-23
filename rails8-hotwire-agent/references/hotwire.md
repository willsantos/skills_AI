# Hotwire: Turbo + Stimulus como interface padrão

## Matriz de escolha

| Necessidade | Opção padrão | Evitar |
|---|---|---|
| Navegar entre páginas e enviar form | Turbo Drive, redirect e HTML | Router SPA e fetch manual |
| Edição inline, paginação/local UI | Turbo Frame | Refazer toda a tela via JavaScript |
| Atualizar lista, contador ou linha após ação | Turbo Streams | Duplicar HTML em templates JS |
| Atualização multiusuário/assíncrona | Broadcast Turbo Streams com escopo seguro | Canal global contendo dados privados |
| Menu, tabs, diálogo, autosave visual, clipboard | Stimulus | Estado de domínio persistido só em JS |

## Exemplo: criação de tarefa

Controller idiomático com fallback HTML e template Stream:

```ruby
# app/controllers/tasks_controller.rb
class TasksController < ApplicationController
  before_action :require_authentication

  def create
    @task = Current.user.tasks.new(task_params)  # adapte ao modelo de autenticação do projeto

    if @task.save
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: "Tarefa criada" }
        format.turbo_stream # renderiza create.turbo_stream.erb
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:title)
  end
end
```

```erb
<%# app/views/tasks/create.turbo_stream.erb %>
<%= turbo_stream.prepend "tasks", partial: "tasks/task", locals: { task: @task } %>
<%= turbo_stream.replace "task_form", partial: "tasks/form", locals: { task: Task.new } %>
```

```erb
<%# app/views/tasks/index.html.erb %>
<div id="tasks">
  <%= render @tasks %>
</div>
<%= turbo_frame_tag "task_form" do %>
  <%= render "form", task: @task || Task.new %>
<% end %>
```

**Importante**: exemplo pressupõe que `Current.user`, associação `tasks`, partial `_task` e `_form` existem. Caso o formulário esteja dentro de um Turbo Frame, GET/POST/invalid responses precisam entregar o `turbo-frame` esperado. Em falhas de validação, retornar o markup do formulário com erros no frame; teste isso com o layout real. Não copiar o exemplo sem ajustar as respostas do projeto.

## Turbo Streams

- Preferir `dom_id(record)` e targets explícitos e únicos.
- Manter HTML em partial compartilhada entre render inicial e atualizações.
- Verificar consistência de coleção em listagem paginada, ordenada ou filtrada (nem sempre `prepend` é correto).
- Transmissão em tempo real: escopo por tenant/usuário e checagem de autorização na assinatura e geração do HTML. Nunca broadcast genérico de HTML privado.
- Confirmar se a atualização é iniciada por submit ou por callback/background job; prevenir broadcasts duplicados.
- `broadcast_*` em callbacks só quando efeito faz parte da regra do produto e não cria efeitos colaterais surpreendentes.

## Stimulus

- Um controller para um comportamento local identificável; `data-controller`, `data-action`, `data-*-target`, `data-*-value`.
- Estado persistido e permissões pertencem ao servidor; Stimulus é responsável por melhorias de interação.
- Limpar timers, listeners, observers e conexões em `disconnect()`.
- Usar lifecycle hooks com cuidado: Turbo pode reconectar controllers após substituir HTML.
- Evitar `document.querySelector` global quando `targets`/`values` forem suficientes.
- Preferir importmap padrão se bastar; usar bundler apenas quando dependências realmente exigirem.

## Critérios de aceite Hotwire

- Usuário autorizado consegue completar a jornada.
- Usuário não autorizado não vê/recebe atualizações privadas.
- HTML normal funciona onde houver fallback.
- Form com erro preserva input e apresenta mensagens; resposta coerente com Turbo Frame.
- Targets Stream existem, são únicos e não provocam DOM inesperado.
- Fluxo crítico é coberto por system test (Capybara/browser), não somente assertion de response.

Referências: https://turbo.hotwired.dev/handbook/introduction ; https://turbo.hotwired.dev/handbook/frames ; https://turbo.hotwired.dev/handbook/streams ; https://stimulus.hotwired.dev/handbook/introduction
