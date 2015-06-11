json.array!(@equipment) do |equipment|
  json.extract! equipment, :id, :equipment, :manufacturer, :klass
  json.url equipment_url(equipment, format: :json)
end
