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
      post :create, assay_kit: { equipment: @assay_kit.equipment, kit_id: @assay_kit.kit_id, manufacturer: @assay_kit.manufacturer }
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
    patch :update, id: @assay_kit, assay_kit: { equipment: @assay_kit.equipment, kit_id: @assay_kit.kit_id, manufacturer: @assay_kit.manufacturer }
    assert_redirected_to assay_kit_path(assigns(:assay_kit))
  end

  test "should destroy assay_kit" do
    assert_difference('AssayKit.count', -1) do
      delete :destroy, id: @assay_kit
    end

    assert_redirected_to assay_kits_path
  end
end
