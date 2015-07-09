class CreateReagents < ActiveRecord::Migration
  def change
    create_table :reagents do |t|
      t.string :name
      t.integer :number
      t.string :unit
      t.string :break_points
      t.belongs_to :assay_kit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
