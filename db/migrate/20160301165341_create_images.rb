class CreateImages < ActiveRecord::Migration
  def change
    create_table :diagnosis_images do |t|
      t.string :protocol
      t.integer :version
      t.string :tag
      t.string :hash_code
      t.attachment :image_file
      t.references :diagnosis_imagable, polymorphic: true, index: { name: 'd_imagable' }

      t.timestamps null: false
    end
  end
end
