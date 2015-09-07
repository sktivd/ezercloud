require 'test_helper'

class ErrorCodesControllerTest < ActionController::TestCase
  setup do
    @error_code = error_codes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:error_codes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create error_code" do
    assert_difference('ErrorCode.count') do
      post :create, error_code: { description: @error_code.description, equipment: @error_code.equipment, error_code: @error_code.error_code, level: @error_code.level }
    end

    assert_redirected_to error_code_path(assigns(:error_code))
  end

  test "should show error_code" do
    get :show, id: @error_code
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @error_code
    assert_response :success
  end

  test "should update error_code" do
    patch :update, id: @error_code, error_code: { description: @error_code.description, equipment: @error_code.equipment, error_code: @error_code.error_code, level: @error_code.level }
    assert_redirected_to error_code_path(assigns(:error_code))
  end

  test "should destroy error_code" do
    assert_difference('ErrorCode.count', -1) do
      delete :destroy, id: @error_code
    end

    assert_redirected_to error_codes_path
  end
end
