class CreateDevices < ActiveRecord::Migration
  def up
    create_table :devices do |t|
      t.string     :serial_number, null: false
      t.references :equipment,     index: true

      t.timestamps null: false
    end
    
    add_reference :diagnoses,    :device, index: true
    Equipment.all.each do |equipment|
      add_reference equipment.db.to_sym, :device, index: true
    end
    
    Device.reset_column_information
    say_with_time 'register existing devices to :devices' do
      Equipment.find_each do |equipment|
        devices = Object.const_get(equipment.klass).uniq.pluck(:serial_number).map do |serial_number|
          Device.new(equipment: equipment, serial_number: serial_number)
        end
        Device.ar_import devices
      end
    end

    Diagnosis.reset_column_information
    say_with_time 'make association between :devices and :diagnoses' do
      Equipment.all.each do |equipment|
        Object.const_get(equipment.klass).reset_column_information
        Device.where(equipment: equipment).find_each do |device|
          Object.const_get(equipment.klass).includes(:diagnosis).where(serial_number: device.serial_number).find_each do |e|
            e.update(device: device)
            e.diagnosis.update_attributes(device: device)
          end
        end
      end
    end
  end
  
  def down
    remove_reference :diagnoses, :device
    drop_table :devices
  end
end
