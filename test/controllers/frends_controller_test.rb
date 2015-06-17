require 'test_helper'

class FrendsControllerTest < ActionController::TestCase
  setup do
    @frend = frends(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:frends)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create frend" do
    assert_difference('Frend.count') do
      post :create, frend: { average_background: @frend.average_background, control_center_point: @frend.control_center_point, control_integral: @frend.control_integral, device_id: @frend.device_id, device_ln: @frend.device_ln, double: @frend.double, error_code: @frend.error_code, external_qc_catalog: @frend.external_qc_catalog, external_qc_level: @frend.external_qc_level, external_qc_ln: @frend.external_qc_ln, external_qc_service_id: @frend.external_qc_service_id, internal_qc_calcaulated_ratio_test: @frend.internal_qc_calcaulated_ratio_test, internal_qc_laser_power_test: @frend.internal_qc_laser_power_test, internal_qc_laseralignment_test: @frend.internal_qc_laseralignment_test, internal_qc_test: @frend.internal_qc_test, manufacturer: @frend.manufacturer, measured_points: @frend.measured_points, point_intensities: @frend.point_intensities, processed: @frend.processed, serial_number: @frend.serial_number, test0_center_point: @frend.test0_center_point, test0_id: @frend.test0_id, test0_integral: @frend.test0_integral, test0_result: @frend.test0_result, test1_center_point: @frend.test1_center_point, test1_id: @frend.test1_id, test1_integral: @frend.test1_integral, test1_result: @frend.test1_result, test2_center_point: @frend.test2_center_point, test2_id: @frend.test2_id, test2_integral: @frend.test2_integral, test2_result: @frend.test2_result, test_type: @frend.test_type, version: @frend.version }
    end

    assert_redirected_to frend_path(assigns(:frend))
  end

  test "should show frend" do
    get :show, id: @frend
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @frend
    assert_response :success
  end

  test "should update frend" do
    patch :update, id: @frend, frend: { average_background: @frend.average_background, control_center_point: @frend.control_center_point, control_integral: @frend.control_integral, device_id: @frend.device_id, device_ln: @frend.device_ln, double: @frend.double, error_code: @frend.error_code, external_qc_catalog: @frend.external_qc_catalog, external_qc_level: @frend.external_qc_level, external_qc_ln: @frend.external_qc_ln, external_qc_service_id: @frend.external_qc_service_id, internal_qc_calcaulated_ratio_test: @frend.internal_qc_calcaulated_ratio_test, internal_qc_laser_power_test: @frend.internal_qc_laser_power_test, internal_qc_laseralignment_test: @frend.internal_qc_laseralignment_test, internal_qc_test: @frend.internal_qc_test, manufacturer: @frend.manufacturer, measured_points: @frend.measured_points, point_intensities: @frend.point_intensities, processed: @frend.processed, serial_number: @frend.serial_number, test0_center_point: @frend.test0_center_point, test0_id: @frend.test0_id, test0_integral: @frend.test0_integral, test0_result: @frend.test0_result, test1_center_point: @frend.test1_center_point, test1_id: @frend.test1_id, test1_integral: @frend.test1_integral, test1_result: @frend.test1_result, test2_center_point: @frend.test2_center_point, test2_id: @frend.test2_id, test2_integral: @frend.test2_integral, test2_result: @frend.test2_result, test_type: @frend.test_type, version: @frend.version }
    assert_redirected_to frend_path(assigns(:frend))
  end

  test "should destroy frend" do
    assert_difference('Frend.count', -1) do
      delete :destroy, id: @frend
    end

    assert_redirected_to frends_path
  end
end
