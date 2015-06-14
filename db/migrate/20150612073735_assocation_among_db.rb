class AssocationAmongDb < ActiveRecord::Migration
  def change
    add_column  :diagnoses, :diagnosable_id,    :integer
    add_column  :diagnoses, :diagnosable_type,  :string
  end
end
