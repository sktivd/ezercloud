class AddDecisionToDiagnosis < ActiveRecord::Migration
  def change
    add_column :diagnoses, :decision, :string, default: 'Suspended'
  end
end
