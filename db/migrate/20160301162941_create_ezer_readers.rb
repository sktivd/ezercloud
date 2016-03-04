class CreateEzerReaders < ActiveRecord::Migration
  def change
    create_table :ezer_readers do |t|
      t.integer :version
      t.string :manufacturer
      t.string :serial_number
      t.boolean :processed
      t.string :error_code
      t.string :kit_maker
      t.string :kit
      t.string :lot
      t.string :test_decision
      t.string :user_comment
      t.string :test_id, null: false, default: ':::::'
      t.string :test_result, null: false, default: ':::::'
      t.string :test_threshold, null: false, default: ':::::'
      t.string :patient_id
      t.string :weather
      t.float :temperature
      t.float :humidity

      t.timestamps null: false
    end
  end
end
