class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :protocol
      t.integer :version
      t.string :tag
      t.string :hash_code
      t.references :imagable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
