require 'test_helper'

class BuddisControllerTest < ActionController::TestCase
  setup do
    @buddi = buddis(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buddis)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create buddi" do
    assert_difference('Buddi.count') do
      post :create, buddi: { control_zone_data: @buddi.control_zone_data, device_expired_date: @buddi.device_expired_date, error_code: @buddi.error_code, kit: @buddi.kit, lot: @buddi.lot, manufacturer: @buddi.manufacturer, patient_id: @buddi.patient_id, processed: @buddi.processed, ratio_data: @buddi.ratio_data, serial_number: @buddi.serial_number, test_zone_data: @buddi.test_zone_data, version: @buddi.version }
    end

    assert_redirected_to buddi_path(assigns(:buddi))
  end

  test "should show buddi" do
    get :show, id: @buddi
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @buddi
    assert_response :success
  end

  test "should update buddi" do
    patch :update, id: @buddi, buddi: { control_zone_data: @buddi.control_zone_data, device_expired_date: @buddi.device_expired_date, error_code: @buddi.error_code, kit: @buddi.kit, lot: @buddi.lot, manufacturer: @buddi.manufacturer, patient_id: @buddi.patient_id, processed: @buddi.processed, ratio_data: @buddi.ratio_data, serial_number: @buddi.serial_number, test_zone_data: @buddi.test_zone_data, version: @buddi.version }
    assert_redirected_to buddi_path(assigns(:buddi))
  end

  test "should destroy buddi" do
    assert_difference('Buddi.count', -1) do
      delete :destroy, id: @buddi
    end

    assert_redirected_to buddis_path
  end
end
