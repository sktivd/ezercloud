json.array!(@equipment) do |equipment|
  json.set! @equipment_name.equipment do
    json.partial! equipment
  end
  json.Diagnosis do
    json.partial! equipment.diagnosis
  end
end
