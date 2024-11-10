class CreateReadings < ActiveRecord::Migration[7.1]
  def change
    create_table :readings do |t|
      t.references :gauge, null: false, foreign_key: true
      t.decimal :value
      t.date :date
      t.boolean :approved, default: false

      t.timestamps
    end
  end
end
