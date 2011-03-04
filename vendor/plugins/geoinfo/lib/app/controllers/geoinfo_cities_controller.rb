class GeoinfoCitiesController < ActionController::Base
  
  def index
    render :text => "test"
    # @cities = City.all
    # 
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @cities }
    # end
  end
end