class AddUserIdToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :user_id, :string, index: true
  end
end
