json.array!(@frends) do |frend|
  json.extract! frend, :id, :version, :manufacturer, :serial_number, :test_type, :processed, :error_code, :kit, :lot, :test_id, :test_result, :integrals, :center_points, :average_background, :measured_points, :point_intensities, :qc_service, :qc_lot, :qc_expire, :internal_qc_laser_power_test, :internal_qc_laseralignment_test, :internal_qc_calculated_ratio_test, :internal_qc_test
#  json.url frend_url(frend, format: :json)
end
