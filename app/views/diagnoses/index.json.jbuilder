json.array!(@diagnoses) do |diagnosis|
  json.extract! diagnosis, :id, :protocol, :version, :authorized_key, :equipment, :measured_at, :elapsed_time, :ip_address, :latitude, :longitude, :data
  json.url diagnosis_url(diagnosis, format: :json)
end
