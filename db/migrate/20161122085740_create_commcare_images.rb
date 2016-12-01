class CreateCommcareImages < ActiveRecord::Migration[5.0]
  def change
    create_table :commcare_images do |t|
      t.integer    :version,    null: false
      t.string     :name,       null: false 
      t.attachment :image_file
      t.references :commcare,   index: true
      t.index      [:commcare_id, :name]
      
      t.timestamps
    end
  end
end
