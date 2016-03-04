require 'test_helper'

class EzerReadersControllerTest < ActionController::TestCase
  setup do
    @ezer_reader = ezer_readers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ezer_readers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ezer_reader" do
    assert_difference('EzerReader.count') do
      post :create, ezer_reader: { error_code: @ezer_reader.error_code, humidity: @ezer_reader.humidity, kit: @ezer_reader.kit, kit_maker: @ezer_reader.kit_maker, lot: @ezer_reader.lot, manufacturer: @ezer_reader.manufacturer, patient_id: @ezer_reader.patient_id, processed: @ezer_reader.processed, serial_number: @ezer_reader.serial_number, temperature: @ezer_reader.temperature, test_decision: @ezer_reader.test_decision, test_id: @ezer_reader.test_id, test_result: @ezer_reader.test_result, test_threshold: @ezer_reader.test_threshold, user_comment: @ezer_reader.user_comment, version: @ezer_reader.version, weather: @ezer_reader.weather }
    end

    assert_redirected_to ezer_reader_path(assigns(:ezer_reader))
  end

  test "should show ezer_reader" do
    get :show, id: @ezer_reader
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @ezer_reader
    assert_response :success
  end

  test "should update ezer_reader" do
    patch :update, id: @ezer_reader, ezer_reader: { error_code: @ezer_reader.error_code, humidity: @ezer_reader.humidity, kit: @ezer_reader.kit, kit_maker: @ezer_reader.kit_maker, lot: @ezer_reader.lot, manufacturer: @ezer_reader.manufacturer, patient_id: @ezer_reader.patient_id, processed: @ezer_reader.processed, serial_number: @ezer_reader.serial_number, temperature: @ezer_reader.temperature, test_decision: @ezer_reader.test_decision, test_id: @ezer_reader.test_id, test_result: @ezer_reader.test_result, test_threshold: @ezer_reader.test_threshold, user_comment: @ezer_reader.user_comment, version: @ezer_reader.version, weather: @ezer_reader.weather }
    assert_redirected_to ezer_reader_path(assigns(:ezer_reader))
  end

  test "should destroy ezer_reader" do
    assert_difference('EzerReader.count', -1) do
      delete :destroy, id: @ezer_reader
    end

    assert_redirected_to ezer_readers_path
  end
end
