require 'test_helper'

class DiagnosesControllerTest < ActionController::TestCase
  setup do
    @diagnosis = diagnoses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:diagnoses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create diagnosis" do
    assert_difference('Diagnosis.count') do
      post :create, diagnosis: { data: @diagnosis.data, day: @diagnosis.day, elapsed_time: @diagnosis.elapsed_time, equipment_id: @diagnosis.equipment_id, hour: @diagnosis.hour, ip_address: @diagnosis.ip_address, latitude: @diagnosis.latitude, longitude: @diagnosis.longitude, manufacturer_id: @diagnosis.manufacturer_id, minute: @diagnosis.minute, month: @diagnosis.month, protocol_id: @diagnosis.protocol_id, second: @diagnosis.second, serial_number: @diagnosis.serial_number, time_zone: @diagnosis.time_zone, version: @diagnosis.version, year: @diagnosis.year }
    end

    assert_redirected_to diagnosis_path(assigns(:diagnosis))
  end

  test "should show diagnosis" do
    get :show, id: @diagnosis
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @diagnosis
    assert_response :success
  end

  test "should update diagnosis" do
    patch :update, id: @diagnosis, diagnosis: { data: @diagnosis.data, day: @diagnosis.day, elapsed_time: @diagnosis.elapsed_time, equipment_id: @diagnosis.equipment_id, hour: @diagnosis.hour, ip_address: @diagnosis.ip_address, latitude: @diagnosis.latitude, longitude: @diagnosis.longitude, manufacturer_id: @diagnosis.manufacturer_id, minute: @diagnosis.minute, month: @diagnosis.month, protocol_id: @diagnosis.protocol_id, second: @diagnosis.second, serial_number: @diagnosis.serial_number, time_zone: @diagnosis.time_zone, version: @diagnosis.version, year: @diagnosis.year }
    assert_redirected_to diagnosis_path(assigns(:diagnosis))
  end

  test "should destroy diagnosis" do
    assert_difference('Diagnosis.count', -1) do
      delete :destroy, id: @diagnosis
    end

    assert_redirected_to diagnoses_path
  end
end
