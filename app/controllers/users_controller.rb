require 'digest/sha1'
class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
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
      redirect_to :action => 'private'
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
      redirect_to :action=> 'login'
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
end
