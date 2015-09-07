json.array!(@error_codes) do |error_code|
  json.extract! error_code, :id, :error_code, :level, :description
  json.url error_code_url(error_code, format: :json)
end
