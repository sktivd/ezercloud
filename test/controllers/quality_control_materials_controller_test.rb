require 'test_helper'

class QualityControlMaterialsControllerTest < ActionController::TestCase
  setup do
    @quality_control_material = quality_control_materials(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quality_control_materials)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quality_control_material" do
    assert_difference('QualityControlMaterial.count') do
      post :create, quality_control_material: { equipment: @quality_control_material.equipment, expire: @quality_control_material.expire, lot_number: @quality_control_material.lot_number, mean: @quality_control_material.mean, reagent_id: @quality_control_material.reagent_id, reagent_name: @quality_control_material.reagent_name, reagent_number: @quality_control_material.reagent_number, sd: @quality_control_material.sd, service: @quality_control_material.service }
    end

    assert_redirected_to quality_control_material_path(assigns(:quality_control_material))
  end

  test "should show quality_control_material" do
    get :show, id: @quality_control_material
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quality_control_material
    assert_response :success
  end

  test "should update quality_control_material" do
    patch :update, id: @quality_control_material, quality_control_material: { equipment: @quality_control_material.equipment, expire: @quality_control_material.expire, lot_number: @quality_control_material.lot_number, mean: @quality_control_material.mean, reagent_id: @quality_control_material.reagent_id, reagent_name: @quality_control_material.reagent_name, reagent_number: @quality_control_material.reagent_number, sd: @quality_control_material.sd, service: @quality_control_material.service }
    assert_redirected_to quality_control_material_path(assigns(:quality_control_material))
  end

  test "should destroy quality_control_material" do
    assert_difference('QualityControlMaterial.count', -1) do
      delete :destroy, id: @quality_control_material
    end

    assert_redirected_to quality_control_materials_path
  end
end
