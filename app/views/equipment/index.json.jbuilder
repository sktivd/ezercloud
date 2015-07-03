json.array!(@equipment) do |equipment|
  json.extract! equipment, :id, :equipment, :manufacturer, :klass, :db, :variable_kit, :variables_test_ids, :variables_test_values, :variable_qc_service, :variable_qc_lotnumber
  json.url equipment_url(equipment, format: :json)
end
