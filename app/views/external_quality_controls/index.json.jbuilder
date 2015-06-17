json.array!(@external_quality_controls) do |external_quality_control|
  json.extract! external_quality_control, :id, :equipment, :device_id, :test_id, :sample_type, :reagent, :lot_number, :expired_at, :unit, :mean, :sd
  json.url external_quality_control_url(external_quality_control, format: :json)
end
