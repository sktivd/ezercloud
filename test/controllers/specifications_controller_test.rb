require 'test_helper'

class SpecificationsControllerTest < ActionController::TestCase
  setup do
    @specification = specifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:specifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create specification" do
    assert_difference('Specification.count') do
      post :create, specification: { acronym: @specification.acronym, allowable_total_error: @specification.allowable_total_error, analyte: @specification.analyte, cv_g: @specification.cv_g, cv_i: @specification.cv_i, imprecision: @specification.imprecision, inaccuracy: @specification.inaccuracy, initial: @specification.initial, papers: @specification.papers }
    end

    assert_redirected_to specification_path(assigns(:specification))
  end

  test "should show specification" do
    get :show, id: @specification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @specification
    assert_response :success
  end

  test "should update specification" do
    patch :update, id: @specification, specification: { acronym: @specification.acronym, allowable_total_error: @specification.allowable_total_error, analyte: @specification.analyte, cv_g: @specification.cv_g, cv_i: @specification.cv_i, imprecision: @specification.imprecision, inaccuracy: @specification.inaccuracy, initial: @specification.initial, papers: @specification.papers }
    assert_redirected_to specification_path(assigns(:specification))
  end

  test "should destroy specification" do
    assert_difference('Specification.count', -1) do
      delete :destroy, id: @specification
    end

    assert_redirected_to specifications_path
  end
end
