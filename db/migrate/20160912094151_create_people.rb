class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.integer    :version,                 null: false
      t.string     :code,                    null: false
      t.string     :encrypted_person,        null: false
      t.string     :encrypted_person_iv,     null: false
      t.string     :encrypted_given_name
      t.string     :encrypted_given_name_iv
      t.string     :encrypted_family_name
      t.string     :encrypted_family_name_iv  
      t.string     :encrypted_sex    
      t.string     :encrypted_sex_iv
      t.string     :encrypted_birthday
      t.string     :encrypted_birthday_iv      
      t.string     :encrypted_phone
      t.string     :encrypted_phone_iv      
      t.string     :encrypted_email
      t.string     :encrypted_email_iv
      t.attachment :id_photo
      t.timestamps                           null: false
    end
  end
end
