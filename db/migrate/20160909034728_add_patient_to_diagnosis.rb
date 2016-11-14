class AddPatientToDiagnosis < ActiveRecord::Migration
  def change
    add_column :diagnoses, :encrypted_person,    :string 
    add_column :diagnoses, :encrypted_person_iv, :string 
  end
end
