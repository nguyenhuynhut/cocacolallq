require File.dirname(__FILE__) + '/test_helper.rb' 
require 'geoinfo_states_controller' 
require 'action_controller/test_process' 

class GeoinfoStatesControllerTest < ActionController::TestCase  
  def test_index 
    get :index  
    assert_response :success  
  end 
end