class CreateAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :assignments do |t|
      t.references :chore, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.date :week_start, null: false
      t.date :scheduled_on, null: false
      t.integer :status, null: false, default: 0
      t.integer :estimate_minutes, null: false, default: 0

      t.timestamps
    end

    add_index :assignments, [:week_start, :chore_id], unique: true
    add_index :assignments, [:week_start, :person_id]
  end
end
