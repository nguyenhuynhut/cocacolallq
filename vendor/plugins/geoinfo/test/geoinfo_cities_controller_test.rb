require File.dirname(__FILE__) + '/test_helper.rb' 
require 'geoinfo_cities_controller' 
require 'action_controller/test_process' 

class GeoinfoCitiesControllerTest < ActionController::TestCase
  def test_index 
    get :index
    assert_response :success  
  end 
end 