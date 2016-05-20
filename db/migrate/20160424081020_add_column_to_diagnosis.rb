class AddColumnToDiagnosis < ActiveRecord::Migration
  def change
    add_column :diagnoses, :diagnosis_tag, :string
  end
end
