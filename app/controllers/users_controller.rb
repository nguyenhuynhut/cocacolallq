require 'digest/sha1'
require 'recaptcha'
require 'yaml'
require 'geoinfo'
class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all
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
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    logger.info 'huyen anh'
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  def confirm
    
    @user = User.new(params[:user])
    unless @user.valid?
      render :action => :new     
    else 
      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @user }
      end
    end
  end
  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.id != @user.id
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
 
    respond_to do |format|
      if @user.save
        format.html { redirect_to(:controller => 'users', :action =>"private", :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    logger.info 'ffffff'
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  def authenticate
    #User.new(params[:userform]) will create a new object of User, retrieve values from the form and store it variable @user.
    @user = User.new(params[:userform])
    #find records with username,password
    valid_user = User.find(:first, :conditions => ["username = ? and password = ?", @user.username, Digest::SHA1.hexdigest(@user.password)])

    #if statement checks whether valid_user exists or not
    if valid_user
      #creates a session with username
      session[:user_id]=valid_user.username
      #redirects the user to our private page.
      redirect_to '/'
    else
      flash[:notice] = "Invalid User/Password"
      redirect_to :action=> 'login'
    end
  end

  def login
  end

  def forgot
  end

  def private

    if !session[:user_id]
      redirect_to :action=> 'login'
    end
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
  end

  def logout
    if session[:user_id]
      reset_session
      redirect_to '/'
    end
  end

  def sendmail
    recipient = params[:mailform][:email]
    subject = 'Get your password'
    user = User.find(:first, :conditions => ["email = ? ", recipient])
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    password = ''
    6.times { |i| password << chars[rand(chars.length)] }

    if user
      user.password = password
      UserMailer.forgot(recipient, subject, user).deliver
      user.update_attributes(:password => password)
    else
      render :text => recipient + " doesn't exist in the system"
      return
    end
    return if request.xhr?
    render :text => 'Message sent successfully'
  end 
  def contact_us
    



  end
  def send_contact_us

    respond_to do |format|
      if verify_recaptcha( :message => "Oh! It's error with reCAPTCHA!")
        recipient = 'nhut2020@yahoo.com'
        subject = params[:contact_us][:subject]
        user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
        message =  params[:contact_us][:message]
        UserMailer.contact_us(recipient, subject, user, message).deliver
        format.html { redirect_to(:controller => 'users', :action =>"private") }
      else
        format.html { redirect_to(:controller => 'users', :action =>"contact_us", :notice => { :error => "Oh! It's error with reCAPTCHA!" ,:subject => params[:contact_us][:subject] , :message => params[:contact_us][:message]})}
      end
    end
  end
  def import_data
    states = File.open( "public/geoinfo_states.yml" )
    YAML::load_documents( states ) { |doc|
      state = GeoinfoState.new
      state.name = doc['name']
      state.abbr = doc['abbr']
      state.country = doc['country']
      state.kind = doc['type']
      state.id = doc['id']
      state.save()
    }

    cities = File.open( "public/geoinfo_cities.yml" )
    YAML::load_documents( cities ) { |doc|
      city = GeoinfoCity.new
      city.name = doc['name']
      city.population_2000 = doc['population_2000']
      city.state_id = doc['state_id']
      city.gnis_id = doc['gnis_id']
      city.latitude = doc['latitude']
      city.longitude = doc['longitude']
      city.save()
    }

  end

end
