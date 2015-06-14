class ChangeDiagnosableOfDiagnoses < ActiveRecord::Migration
  def up
    remove_column :diagnoses, :diagnosable_id
    remove_column :diagnoses, :diagnosable_type
    add_reference :diagnoses, :diagnosable, polymorphic: true, index: true
  end

  def down
    add_column    :diagnoses, :diagnosable_id,    :integer
    add_column    :diagnoses, :diagnosable_type,  :string
    add_reference :diagnoses, :diagnosable, polymorphic: true, index: true
  end
end
