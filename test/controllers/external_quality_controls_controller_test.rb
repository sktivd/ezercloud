require 'test_helper'

class ExternalQualityControlsControllerTest < ActionController::TestCase
  setup do
    @external_quality_control = external_quality_controls(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:external_quality_controls)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create external_quality_control" do
    assert_difference('ExternalQualityControl.count') do
      post :create, external_quality_control: { device_id: @external_quality_control.device_id, equipment: @external_quality_control.equipment, expired_at: @external_quality_control.expired_at, lot_number: @external_quality_control.lot_number, mean: @external_quality_control.mean, reagent: @external_quality_control.reagent, sample_type: @external_quality_control.sample_type, sd: @external_quality_control.sd, test_id: @external_quality_control.test_id, unit: @external_quality_control.unit }
    end

    assert_redirected_to external_quality_control_path(assigns(:external_quality_control))
  end

  test "should show external_quality_control" do
    get :show, id: @external_quality_control
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @external_quality_control
    assert_response :success
  end

  test "should update external_quality_control" do
    patch :update, id: @external_quality_control, external_quality_control: { device_id: @external_quality_control.device_id, equipment: @external_quality_control.equipment, expired_at: @external_quality_control.expired_at, lot_number: @external_quality_control.lot_number, mean: @external_quality_control.mean, reagent: @external_quality_control.reagent, sample_type: @external_quality_control.sample_type, sd: @external_quality_control.sd, test_id: @external_quality_control.test_id, unit: @external_quality_control.unit }
    assert_redirected_to external_quality_control_path(assigns(:external_quality_control))
  end

  test "should destroy external_quality_control" do
    assert_difference('ExternalQualityControl.count', -1) do
      delete :destroy, id: @external_quality_control
    end

    assert_redirected_to external_quality_controls_path
  end
end
