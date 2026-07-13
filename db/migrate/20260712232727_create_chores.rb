class CreateChores < ActiveRecord::Migration[8.0]
  def change
    create_table :chores do |t|
      t.string :name, null: false
      t.integer :base_estimate_minutes, null: false, default: 15
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
