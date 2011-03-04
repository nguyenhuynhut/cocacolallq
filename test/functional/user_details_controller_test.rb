require 'test_helper'

class UserDetailsControllerTest < ActionController::TestCase
  setup do
    @user_detail = user_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_detail" do
    assert_difference('UserDetail.count') do
      post :create, :user_detail => @user_detail.attributes
    end

    assert_redirected_to user_detail_path(assigns(:user_detail))
  end

  test "should show user_detail" do
    get :show, :id => @user_detail.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user_detail.to_param
    assert_response :success
  end

  test "should update user_detail" do
    put :update, :id => @user_detail.to_param, :user_detail => @user_detail.attributes
    assert_redirected_to user_detail_path(assigns(:user_detail))
  end

  test "should destroy user_detail" do
    assert_difference('UserDetail.count', -1) do
      delete :destroy, :id => @user_detail.to_param
    end

    assert_redirected_to user_details_path
  end
end
