require 'test_helper'

class CriteriasControllerTest < ActionController::TestCase
  setup do
    @criteria = criterias(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:criterias)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create criteria" do
    assert_difference('Criteria.count') do
      post :create, :criteria => @criteria.attributes
    end

    assert_redirected_to criteria_path(assigns(:criteria))
  end

  test "should show criteria" do
    get :show, :id => @criteria.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @criteria.to_param
    assert_response :success
  end

  test "should update criteria" do
    put :update, :id => @criteria.to_param, :criteria => @criteria.attributes
    assert_redirected_to criteria_path(assigns(:criteria))
  end

  test "should destroy criteria" do
    assert_difference('Criteria.count', -1) do
      delete :destroy, :id => @criteria.to_param
    end

    assert_redirected_to criterias_path
  end
end
