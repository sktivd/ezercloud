json.array!(@diagnoses) do |diagnosis|
  json.extract! diagnosis, :order_number, :equipment, :measured_at, :ip_address, :location, :created_at, :technician
#  json.url diagnosis_url(diagnosis, format: :json)
end
