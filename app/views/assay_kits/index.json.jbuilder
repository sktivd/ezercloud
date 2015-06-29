json.array!(@assay_kits) do |assay_kit|
  json.extract! assay_kit, :id, :equipment, :manufacturer, :kit
  json.url assay_kit_url(assay_kit, format: :json)
end
