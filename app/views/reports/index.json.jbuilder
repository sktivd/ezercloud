json.array!(@reports) do |report|
  json.extract! report, :id, :equipment, :serial_number, :date, :reagent_id
  json.url report_url(report, format: :json)
end
