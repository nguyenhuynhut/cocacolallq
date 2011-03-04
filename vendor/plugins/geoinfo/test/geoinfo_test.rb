require 'test_helper'

class GeoinfoTest < ActiveSupport::TestCase
  load_schema
  
  class State < ActiveRecord::Base
  end
  
  class City < ActiveRecord::Base
  end
  
  def test_schema_has_loaded_correctly
    assert_equal [], State.all
    assert_equal [], City.all
  end
end
