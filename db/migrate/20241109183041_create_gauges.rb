class CreateGauges < ActiveRecord::Migration[7.1]
  def change
    create_table :gauges do |t|
      t.string :name
      t.date :start_date
      t.date :end_date
      t.integer :unit, default: 0, null: false
      t.integer :time_unit, default: 0, null: false 

      t.timestamps
    end
  end
end
