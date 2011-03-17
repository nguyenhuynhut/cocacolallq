class UserDetailsController < ApplicationController
  # GET /user_details
  # GET /user_details.xml
  def index
    @user_details = UserDetail.all
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.username != 'admin'
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
      format.xml  { render :xml => @user_details }
    end
  end

  # GET /user_details/1
  # GET /user_details/1.xml
  def show
    @user_detail = UserDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_detail }
    end
  end

  # GET /user_details/new
  # GET /user_details/new.xml
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
    @user_detail = UserDetail.new
    @cities_first = GeoinfoCity.where(:state_id => '2').find :all, :order => "name asc"
    @selected_city = nil
    logger.info @cities_first
    if @user_detail.city_id
      @selected_city = GeoinfoCity.find(@user_detail.city_id)

    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_detail }
    end
  end

  # GET /user_details/1/edit
  def edit
    @user_detail = UserDetail.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.id != @user_detail.user_id
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
   
    @state_first = GeoinfoState.find(@user_detail.state_id)
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if @user_detail.city_id
      @selected_city = GeoinfoCity.find(@user_detail.city_id)

    end

  end

  # POST /user_details
  # POST /user_details.xml
  def create
    @user_detail = UserDetail.new(params[:user_detail])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @user_detail.user_id = @valid_user.id
    @valid_user.user_detail = @user_detail
    @valid_user.save
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
    if params[:user_detail][:state_id]
      @state_first = GeoinfoState.find(params[:user_detail][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:user_detail][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:user_detail][:city_id]).first

    end
    respond_to do |format|
      if @user_detail.save
        if params[:logo] then
          @user_detail.savelogo(params[:logo])
        end
        format.html { redirect_to(@user_detail, :notice => 'User detail was successfully created.') }
        format.xml  { render :xml => @user_detail, :status => :created, :location => @user_detail }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_details/1
  # PUT /user_details/1.xml
  def update
    @user_detail = UserDetail.find(params[:id])

    respond_to do |format|
      if @user_detail.update_attributes(params[:user_detail])
        if params[:logo] then
          @user_detail.savelogo(params[:logo])
        end
        format.html { redirect_to(@user_detail, :notice => 'User detail was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_details/1
  # DELETE /user_details/1.xml
  def destroy
    @user_detail = UserDetail.find(params[:id])
    @user_detail.destroy

    respond_to do |format|
      format.html { redirect_to(user_details_url) }
      format.xml  { head :ok }
    end
  end
end
