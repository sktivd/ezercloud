json.array!(@frends) do |frend|
  json.extract! frend, :id, :version, :manufacturer, :serial_number, :test_type, :processed, :error_code, :device_id, :device_ln, :test0_id, :test1_id, :test2_id, :test0_result, :test1_result, :test2_result, :test0_integral, :test1_integral, :test2_integral, :control_integral, :double, :test0_center_point, :test1_center_point, :test2_center_point, :control_center_point, :average_background, :measured_points, :point_intensities, :external_qc_service_id, :external_qc_catalog, :external_qc_ln, :external_qc_level, :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calcaulated_ratio_test, :internal_qc_test
  json.url frend_url(frend, format: :json)
end
