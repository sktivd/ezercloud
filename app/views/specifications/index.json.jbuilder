json.array!(@specifications) do |specification|
  json.extract! specification, :id, :specimen, :analyte, :acronym, :papers, :cv_i, :cv_g, :imprecision, :inaccuracy, :allowable_total_error
  json.url specification_url(specification, format: :json)
end
