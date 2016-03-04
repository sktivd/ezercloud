json.array!(@images) do |image|
  json.extract! image, :id, :protocol, :version, :tag
  json.url image_url(image, format: :json)
end
