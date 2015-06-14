class RemoveAuthorizedKeyOfDiagnoses < ActiveRecord::Migration
  def up
    remove_column :diagnoses, :authorized_key
  end
  
  def down
    add_column :diagnosis, :authorized_key, :string
  end
end
