class AddEveryToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :every, :integer
    add_column :notifications, :redirect_path, :string
  end
end
