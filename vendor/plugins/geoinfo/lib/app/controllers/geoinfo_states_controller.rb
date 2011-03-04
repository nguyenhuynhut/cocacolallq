class GeoinfoStatesController < ActionController::Base
  
  def index
    render :text => "test"
    # @states = State.all
    # 
    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render :xml => @states }
    # end
  end
end