class CreatePlates < ActiveRecord::Migration
  def change
    create_table :plates do |t|
      t.belongs_to :assay_kit, index: true, foreign_key: true
      t.belongs_to :reagent, index: true, foreign_key: true

      t.timestamps null: false
    end    
  end
end
