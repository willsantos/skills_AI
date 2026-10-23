require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "validates and normalizes title" do
    task = users(:alice).tasks.new(title: "  Example  ")
    assert task.valid?
    assert_equal "Example", task.title
    task.title = " "
    assert_not task.valid?
    task.title = "x" * 201
    assert_not task.valid?
  end

  test "database constraint protects bulk writes that skip validations" do
    assert_raises(ActiveRecord::StatementInvalid) do
      Task.where(id: tasks(:alice_task).id).update_all(title: "")
    end
  end

  test "stale edits cannot overwrite a newer version" do
    first = Task.find(tasks(:alice_task).id)
    second = Task.find(first.id)
    first.update!(title: "Newer title")
    assert_raises(ActiveRecord::StaleObjectError) { second.update!(title: "Stale title") }
    assert_equal "Newer title", first.reload.title
  end
end
