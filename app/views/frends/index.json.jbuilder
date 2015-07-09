json.array!(@frends) do |frend|
  json.extract! frend, :id, :version, :manufacturer, :serial_number, :test_type, :processed, :error_code, :device_id, :device_lot, :test_id0, :test_id1, :test_id2, :test_result0, :test_result1, :test_result2, :test_integral0, :test_integral1, :test_integral2, :control_integral, :test_center_point0, :test_center_point1, :test_center_point2, :control_center_point, :average_background, :measured_points, :point_intensities, :qc_service, :qc_lot, :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calcaulated_ratio_test, :internal_qc_test
  json.url frend_url(frend, format: :json)
end
