require File.dirname(__FILE__) + '/test_helper.rb'

class GeoinfoStateTest < Test::Unit::TestCase
  load_schema
  
  def test_state
    assert_kind_of GeoinfoState, GeoinfoState.new
  end
end