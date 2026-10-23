class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.boolean :completed, null: false, default: false
      t.integer :completion_count, null: false, default: 0
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    add_check_constraint :tasks, "length(trim(title)) > 0 AND length(title) <= 200", name: "tasks_title_valid"
    add_check_constraint :tasks, "completion_count >= 0 AND completion_count <= 1", name: "tasks_completion_once"
  end
end
