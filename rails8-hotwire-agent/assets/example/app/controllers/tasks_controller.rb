class TasksController < ApplicationController
  def index
    @tasks = Current.user.tasks.order(created_at: :desc, id: :desc)
    @task = Current.user.tasks.new
  end

  def new
    @task = Current.user.tasks.new
  end

  def show
    @task = Current.user.tasks.find(params[:id])
  end

  def create
    @task = Current.user.tasks.new(params.require(:task).permit(:title))

    if @task.save
      respond_to do |format|
        format.html { redirect_to tasks_path, notice: "Tarefa criada", status: :see_other }
        format.turbo_stream
      end
    else
      render :new, formats: [ :html ], status: :unprocessable_entity
    end
  end

  def update
    @task = Current.user.tasks.find(params[:id])
    if @task.update(params.require(:task).permit(:title, :lock_version))
      redirect_to tasks_path, status: :see_other
    else
      render :new, formats: [ :html ], status: :unprocessable_entity
    end
  rescue ActiveRecord::StaleObjectError
    head :conflict
  end
end
