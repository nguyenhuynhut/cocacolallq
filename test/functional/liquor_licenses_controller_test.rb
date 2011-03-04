require 'test_helper'

class LiquorLicensesControllerTest < ActionController::TestCase
  setup do
    @liquor_license = liquor_licenses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:liquor_licenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create liquor_license" do
    assert_difference('LiquorLicense.count') do
      post :create, :liquor_license => @liquor_license.attributes
    end

    assert_redirected_to liquor_license_path(assigns(:liquor_license))
  end

  test "should show liquor_license" do
    get :show, :id => @liquor_license.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @liquor_license.to_param
    assert_response :success
  end

  test "should update liquor_license" do
    put :update, :id => @liquor_license.to_param, :liquor_license => @liquor_license.attributes
    assert_redirected_to liquor_license_path(assigns(:liquor_license))
  end

  test "should destroy liquor_license" do
    assert_difference('LiquorLicense.count', -1) do
      delete :destroy, :id => @liquor_license.to_param
    end

    assert_redirected_to liquor_licenses_path
  end
end
