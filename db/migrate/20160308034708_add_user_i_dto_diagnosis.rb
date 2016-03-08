class AddUserIDtoDiagnosis < ActiveRecord::Migration
  def change
    add_column :diagnoses, :user_id, :string
  end
end
