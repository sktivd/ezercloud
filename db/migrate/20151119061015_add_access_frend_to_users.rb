class AddAccessFrendToUsers < ActiveRecord::Migration
  def change
    add_column :users, :equipment_frends, :boolean, default: false
    add_column :users, :full_name, :string, default: ""
  end
end
