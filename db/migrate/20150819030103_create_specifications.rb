class CreateSpecifications < ActiveRecord::Migration
  def change
    create_table :specifications do |t|
      t.string :specimen
      t.string :analyte
      t.string :acronym
      t.integer :papers
      t.float :cv_i
      t.float :cv_g
      t.float :imprecision
      t.float :inaccuracy
      t.float :allowable_total_error
      t.belongs_to :reagent, index: true

      t.timestamps null: false
    end
  end
end
