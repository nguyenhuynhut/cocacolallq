require 'geoinfo'
class CriteriasController < ApplicationController
  # GET /criterias
  # GET /criterias.xml
  def index
   
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @criterias = Criteria.where(:user_id => @valid_user.id)
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user == nil
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @criterias }
    end
  end

  # GET /criterias/1
  # GET /criterias/1.xml
  def show
    @criteria = Criteria.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @criteria }
    end
  end
  # DELETE /liquor_licenses/1
  # DELETE /liquor_licenses/1.xml
  def delete_record
    @criteria = Criteria.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.id != @criteria.user_id
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
    @criteria.destroy
    redirect_to(request.env["HTTP_REFERER"])

  end
  # GET /criterias/new
  # GET /criterias/new.xml
  def new
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user == nil
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
    @criteria = Criteria.new
    @cities_first = GeoinfoCity.where(:state_id => '2').find :all, :order => "name asc"
    @selected_city = nil
    logger.info @cities_first
    if @criteria.city_id
      @selected_city = GeoinfoCity.find(@criteria.city_id)

    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @criteria }
    end
  end

  # GET /criterias/1/edit
  def edit
    @criteria = Criteria.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.id != @criteria.user_id
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
    @state_first = GeoinfoState.find(@criteria.state_id)
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
    @selected_city = nil
    if @criteria.city_id
      @selected_city = GeoinfoCity.find(@criteria.city_id)

    end

  end

  # POST /criterias
  # POST /criterias.xml
  def create
    @criteria = Criteria.new(params[:criteria])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @criteria.user_id = @valid_user.id
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
    if params[:criteria][:state_id]
      @state_first = GeoinfoState.find(params[:criteria][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:criteria][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:criteria][:city_id]).first

    end
    @same_criteria = Criteria.where( :user_id => @valid_user.id , :license_type_id => params[:criteria][:license_type_id], :city_id => params[:criteria][:city_id], :state_id => params[:criteria][:state_id]).first
    if @same_criteria
      @criteria.errors.add(:base, "The criterion is existed")
      respond_to do |format|

        render :action => "new"
        
        return false
      end
    end
    respond_to do |format|
      if @criteria.save
        format.html { redirect_to(@criteria, :notice => 'Criteria was successfully created.') }
        format.xml  { render :xml => @criteria, :status => :created, :location => @criteria }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @criteria.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /criterias/1
  # PUT /criterias/1.xml
  def update
    @criteria = Criteria.find(params[:id])
    @same_criteria = Criteria.where( :user_id => @criteria.user_id , :license_type_id => params[:criteria][:license_type_id], :city_id => params[:criteria][:city_id], :state_id => params[:criteria][:state_id]).first
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
    if params[:criteria][:state_id]
      @state_first = GeoinfoState.find(params[:criteria][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:criteria][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:criteria][:city_id]).first

    end
    if @same_criteria
      @criteria.errors.add(:base, "The criterion is existed")
      respond_to do |format|

        render :action => "edit"
        
        return false
      end
    end
    
    respond_to do |format|
      if @criteria.update_attributes(params[:criteria])
        format.html { redirect_to(@criteria, :notice => 'Criteria was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @criteria.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /criterias/1
  # DELETE /criterias/1.xml
  def destroy
    @criteria = Criteria.find(params[:id])
    @criteria.destroy

    respond_to do |format|
      format.html { redirect_to(criterias_url) }
      format.xml  { head :ok }
    end
  end

end
