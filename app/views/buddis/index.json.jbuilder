json.array!(@buddis) do |buddi|
  json.extract! buddi, :id, :version, :manufacturer, :serial_number, :processed, :error_code, :kit, :lot, :device_expired_date, :patient_id, :test_zone_data, :control_zone_data, :ratio_data
  json.url buddi_url(buddi, format: :json)
end
