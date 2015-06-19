require 'test_helper'

class AssayKitsControllerTest < ActionController::TestCase
  setup do
    @assay_kit = assay_kits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assay_kits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assay_kit" do
    assert_difference('AssayKit.count') do
      post :create, assay_kit: { device_id: @assay_kit.device_id, equipment: @assay_kit.equipment, manufacturer: @assay_kit.manufacturer, number_of_tests: @assay_kit.number_of_tests, reagent: @assay_kit.reagent, test_id: @assay_kit.test_id }
    end

    assert_redirected_to assay_kit_path(assigns(:assay_kit))
  end

  test "should show assay_kit" do
    get :show, id: @assay_kit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @assay_kit
    assert_response :success
  end

  test "should update assay_kit" do
    patch :update, id: @assay_kit, assay_kit: { device_id: @assay_kit.device_id, equipment: @assay_kit.equipment, manufacturer: @assay_kit.manufacturer, number_of_tests: @assay_kit.number_of_tests, reagent: @assay_kit.reagent, test_id: @assay_kit.test_id }
    assert_redirected_to assay_kit_path(assigns(:assay_kit))
  end

  test "should destroy assay_kit" do
    assert_difference('AssayKit.count', -1) do
      delete :destroy, id: @assay_kit
    end

    assert_redirected_to assay_kits_path
  end
end
