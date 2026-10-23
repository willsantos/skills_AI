require "test_helper"

class CompleteTaskJobTest < ActiveJob::TestCase
  test "job is enqueued with explicit owner and record IDs" do
    assert_enqueued_with(job: CompleteTaskJob, args: [users(:alice).id, tasks(:alice_task).id]) do
      CompleteTaskJob.perform_later(users(:alice).id, tasks(:alice_task).id)
    end
  end

  test "repeated local completion has one effect" do
    task = tasks(:alice_task)
    2.times { CompleteTaskJob.perform_now(users(:alice).id, task.id) }
    assert task.reload.completed?
    assert_equal 1, task.completion_count
    assert_equal 1, task.lock_version
  end

  test "wrong owner cannot complete a task" do
    CompleteTaskJob.perform_now(users(:alice).id, tasks(:bob_task).id)
    assert_not tasks(:bob_task).reload.completed?
    assert_equal 0, tasks(:bob_task).completion_count
  end

  test "removed task is safe to reprocess" do
    task = tasks(:alice_task)
    id = task.id
    task.destroy!
    assert_nothing_raised { CompleteTaskJob.perform_now(users(:alice).id, id) }
  end
end
