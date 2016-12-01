class CreateCommcares < ActiveRecord::Migration[5.0]
  def change
    create_table :commcares do |t|
      t.integer    :version,          null: false
      t.string     :app_id,           null: false
      t.string     :form,             null: false, index: true
      t.string     :name
      t.datetime   :measured_at,      null: false
      t.datetime   :received_at,      null: false
      t.text       :encrypted_raw
      t.text       :encrypted_raw_iv
      t.string     :encrypted_agreement_signature
      t.string     :encrypted_agreement_signature_iv
      t.references :person,           index: true
      
      t.timestamps
    end
    
    add_index :people, :code
  end
end
