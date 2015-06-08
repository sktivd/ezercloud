json.array!(@diagnoses) do |diagnosis|
  json.extract! diagnosis, :id, :protocol_id, :version, :manufacturer_id, :equipment_id, :serial_number, :year, :month, :day, :hour, :minute, :second, :time_zone, :elapsed_time, :ip_address, :latitude, :longitude, :data
  json.url diagnosis_url(diagnosis, format: :json)
end
