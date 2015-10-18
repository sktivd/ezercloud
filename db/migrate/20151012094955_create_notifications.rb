class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :follow, null:false, default: 0
      t.string :authentication_key, null: false
      t.string :tag, null: false
      t.text :url
      t.text :message
      t.text :data
      t.string :mailer
      t.datetime :sent_at
      t.datetime :notified_at
      t.datetime :expired_at, null: false, default: 1.days.from_now
      t.references :user, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
