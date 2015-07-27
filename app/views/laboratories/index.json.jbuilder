json.array!(@laboratories) do |laboratory|
  json.extract! laboratory, :id, :ip_address, :equipment, :kit
  json.url laboratory_url(laboratory, format: :json)
end
