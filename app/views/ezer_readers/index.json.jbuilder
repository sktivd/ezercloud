json.array!(@ezer_readers) do |ezer_reader|
  json.extract! ezer_reader, :id, :version, :manufacturer, :serial_number, :processed, :error_code, :kit_maker, :kit, :lot, :test_decision, :user_comment, :test_id, :test_result, :test_threshold, :patient_id, :weather, :temperature, :humidity
  json.url ezer_reader_url(ezer_reader, format: :json)
end
