class CompleteTaskJob < ApplicationJob
  queue_as :default

  def perform(user_id, task_id)
    # Single conditional SQL statement, scoped by owner. Local effect only:
    # no HTTP calls, callbacks or claim of exactly-once external delivery.
    Task.where(user_id: user_id, id: task_id, completed: false).update_all(
      "completed = TRUE, completion_count = completion_count + 1, lock_version = lock_version + 1"
    )
  end
end
