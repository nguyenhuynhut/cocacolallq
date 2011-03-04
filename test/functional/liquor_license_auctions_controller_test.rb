require 'test_helper'

class LiquorLicenseAuctionsControllerTest < ActionController::TestCase
  setup do
    @liquor_license_auction = liquor_license_auctions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:liquor_license_auctions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create liquor_license_auction" do
    assert_difference('LiquorLicenseAuction.count') do
      post :create, :liquor_license_auction => @liquor_license_auction.attributes
    end

    assert_redirected_to liquor_license_auction_path(assigns(:liquor_license_auction))
  end

  test "should show liquor_license_auction" do
    get :show, :id => @liquor_license_auction.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @liquor_license_auction.to_param
    assert_response :success
  end

  test "should update liquor_license_auction" do
    put :update, :id => @liquor_license_auction.to_param, :liquor_license_auction => @liquor_license_auction.attributes
    assert_redirected_to liquor_license_auction_path(assigns(:liquor_license_auction))
  end

  test "should destroy liquor_license_auction" do
    assert_difference('LiquorLicenseAuction.count', -1) do
      delete :destroy, :id => @liquor_license_auction.to_param
    end

    assert_redirected_to liquor_license_auctions_path
  end
end
