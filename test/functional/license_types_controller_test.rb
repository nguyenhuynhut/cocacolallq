require 'test_helper'

class LicenseTypesControllerTest < ActionController::TestCase
  setup do
    @license_type = license_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:license_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create license_type" do
    assert_difference('LicenseType.count') do
      post :create, :license_type => @license_type.attributes
    end

    assert_redirected_to license_type_path(assigns(:license_type))
  end

  test "should show license_type" do
    get :show, :id => @license_type.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @license_type.to_param
    assert_response :success
  end

  test "should update license_type" do
    put :update, :id => @license_type.to_param, :license_type => @license_type.attributes
    assert_redirected_to license_type_path(assigns(:license_type))
  end

  test "should destroy license_type" do
    assert_difference('LicenseType.count', -1) do
      delete :destroy, :id => @license_type.to_param
    end

    assert_redirected_to license_types_path
  end
end
