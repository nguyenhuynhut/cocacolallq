require File.dirname(__FILE__) + '/test_helper.rb'

class GeoinfoCityTest < Test::Unit::TestCase
  load_schema
  
  def test_state
    assert_kind_of GeoinfoCity, GeoinfoCity.new
  end
end