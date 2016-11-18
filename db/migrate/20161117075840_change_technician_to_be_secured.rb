class ChangeTechnicianToBeSecured < ActiveRecord::Migration[5.0]
  
  def encryption_key
    raise 'ATTR_ENCRYPTED_KEY environmental variable is prerequisite!' if Rails.env.production? && ENV['ATTR_ENCRYPTED_KEY'].nil?
    ENV['ATTR_ENCRYPTED_KEY'] || 'test_key'
  end
  
  def up
    rename_column :diagnoses, :technician, :plain_technician
    add_column :diagnoses, :encrypted_technician, :string
    add_column :diagnoses, :encrypted_technician_iv, :string
    
    Diagnosis.reset_column_information
    say_with_time 'Encrypt technician in diagnoses' do
      Diagnosis.find_each do |t|
        t.technician = t.plain_technician
        t.save
      end
    end
    
    remove_column :diagnoses, :plain_technician
  end
  
  def down
    unencrypt_field :diagnoses, :technician, key: :encryption_key
  end
  
end
