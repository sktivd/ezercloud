# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( pie_markerclusterer/markerclusterer.js pie_markerclusterer/data.json pie_markerclusterer/*.png )

%w( account_validations assay_kits diagnoses diagnosis_images equipment google_maps laboratories notifications quality_control_materials reagents reports responses session specifications users ).each do |controller|
  Rails.application.config.assets.precompile += ["#{controller}.coffee", "#{controller}.js", "#{controller}.scss", "#{controller}.css"]
end

## AmCharts
#%w( amcharts funnel gantt gauge pie radar serial xy ).each do |chart|
#  Rails.application.config.assets.precompile.push "amcharts/#{chart}.js"
#end