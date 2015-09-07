class CreateErrorCodes < ActiveRecord::Migration
  def change
    create_table :error_codes do |t|
      t.string :error_code
      t.string :level
      t.string :description
      t.belongs_to :equipment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
