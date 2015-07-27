json.array!(@quality_control_materials) do |quality_control_material|
  json.extract! quality_control_material, :id, :service, :lot, :expire, :equipment, :reagent_name, :reagent_number, :n_equipment, :n_measurement, :mean, :sd, :reagent_id
  json.url quality_control_material_url(quality_control_material, format: :json)
end
