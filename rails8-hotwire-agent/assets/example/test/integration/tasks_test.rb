require "test_helper"

class TasksTest < ActionDispatch::IntegrationTest
  def login
    post session_path, params: { email_address: users(:alice).email_address, password: "password-for-tests" }
    assert_response :redirect
  end

  test "anonymous access requires authentication" do
    get tasks_path
    assert_redirected_to new_session_path
  end

  test "index only shows owned tasks" do
    login
    get tasks_path
    assert_response :success
    assert_select "article", text: "Alice private task"
    assert_select "article", text: "Bob private task", count: 0
  end

  test "another owner cannot read or update a task" do
    login
    get task_path(tasks(:bob_task))
    assert_response :not_found
    patch task_path(tasks(:bob_task)), params: { task: { title: "Attack" } }
    assert_response :not_found
    assert_equal "Bob private task", tasks(:bob_task).reload.title
  end

  test "creation ignores client supplied owner and redirects with 303" do
    login
    assert_difference("Task.count", 1) do
      post tasks_path, params: { task: { title: "New", user_id: users(:bob).id, completed: true } }
    end
    assert_response :see_other
    assert_equal users(:alice).id, Task.order(:id).last.user_id
    assert_not Task.order(:id).last.completed?
  end

  test "turbo creation preserves the frame wrapper" do
    login
    post tasks_path, params: { task: { title: "Turbo" } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_select 'turbo-stream[action="prepend"][target="tasks"]'
    assert_select 'turbo-stream[action="update"][target="task_form"]'
    assert_select 'turbo-stream[action="replace"][target="task_form"]', count: 0
  end

  test "invalid turbo submission preserves input and returns matching HTML frame" do
    login
    assert_no_difference("Task.count") do
      post tasks_path, params: { task: { title: "x" * 201 } }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end
    assert_response :unprocessable_entity
    assert_equal "text/html", response.media_type
    assert_select 'turbo-frame#task_form input[name="task[title]"][value=?]', "x" * 201
    assert_select 'turbo-frame#task_form [role="alert"]'
  end

  test "stale browser form returns conflict instead of overwriting" do
    login
    task = tasks(:alice_task)
    original_version = task.lock_version
    task.update!(title: "Fresh")
    patch task_path(task), params: { task: { title: "Stale", lock_version: original_version } }
    assert_response :conflict
    assert_equal "Fresh", task.reload.title
  end
end
