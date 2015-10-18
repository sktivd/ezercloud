class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :email
      t.boolean :privilege_super, default: false
      t.boolean :privilege_reagent, default: false
      t.boolean :privilege_notification, default: false

      t.timestamps null: false
    end
  end
end
