class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :equipment
      t.string :serial_number
      t.date :date
      t.datetime :transmitted_at
      t.belongs_to :reagent, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
