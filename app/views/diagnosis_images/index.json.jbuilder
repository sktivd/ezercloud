json.array!(@diagnosis_images) do |diagnosis_image|
  json.extract! diagnosis_image, :id, :protocol, :version, :tag
  json.url diagnosis_image_url(diagnosis_image, format: :json)
end
