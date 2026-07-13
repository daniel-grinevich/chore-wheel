class CreateWorkSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :work_sessions do |t|
      t.references :assignment, null: false, foreign_key: true
      t.datetime :started_at, null: false
      t.datetime :ended_at
      t.integer :duration_seconds

      t.timestamps
    end
  end
end
