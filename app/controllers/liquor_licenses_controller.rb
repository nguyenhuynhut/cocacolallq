require 'geoinfo'
require 'nokogiri'
require 'open-uri'
require "sortable_table"
class LiquorLicensesController < ApplicationController
  # GET /liquor_licenses
  # GET /liquor_licenses.xml
  sortable_attributes :title , :city_id, :state_id , :expiration_date, :price, :license_type_id
  def index
    result = LiquorLicense.joins(:user).where("users.username != :username", {:username => session[:user_id]})
    @liquor_licenses = result.paginate(:page => params[:page] ,:per_page => 1)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @liquor_licenses }
    end
  end
  # GET /liquor_licenses/1
  # GET /liquor_licenses/1.xml
  def view
    @liquor_license = LiquorLicense.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @liquor_license_auction =LiquorLicenseAuction.where(:liquor_license_id => params[:id], :bidder_id =>  @valid_user.id).first
    if params[:auction] and params[:auction][:bid] != '' and params[:auction][:bid].to_f > 0
      recipient = @liquor_license.user.email
      subject = "Bid Your Liquor License"
      message = params[:auction][:message]
      UserMailer.bid(recipient, subject, @valid_user, message, @liquor_license, params[:auction][:bid]).deliver
      if @liquor_license_auction != nil
        
        @liquor_license_auction.price = params[:auction][:bid].to_f
        @liquor_license_auction.status = false
        @liquor_license_auction.save()
      else
        logger.info 'abc'
        @liquor_license_auction = LiquorLicenseAuction.new
        @liquor_license_auction.price = params[:auction][:bid].to_f
        @liquor_license_auction.liquor_license = @liquor_license
        @liquor_license_auction.status = false
        @liquor_license_auction.bidder = @valid_user
        @liquor_license_auction.user = @liquor_license.user
        @liquor_license_auction.save()
        
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @liquor_license }
    end
  end
  # GET /liquor_licenses/1
  # GET /liquor_licenses/1.xml
  def show
    @liquor_license = LiquorLicense.find(params[:id])
    @liquor_license_auctions = LiquorLicenseAuction.where(:liquor_License_id  => params[:id]).find :all, :order => 'price desc'
    logger.info @liquor_license_auctions
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @liquor_license }
    end
  end

  # GET /liquor_licenses/new
  # GET /liquor_licenses/new.xml
  def new
    @liquor_license = LiquorLicense.new
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @liquor_license }
    end
  end

  # GET /liquor_licenses/1/edit
  def edit
    @liquor_license = LiquorLicense.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @state_first = GeoinfoState.find(@liquor_license.state_id)
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if @liquor_license.city_id
      @selected_city = GeoinfoCity.find(@liquor_license.city_id)

    end
  end

  # POST /liquor_licenses
  # POST /liquor_licenses.xml
  def create
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @liquor_license = @valid_user.liquor_licenses.create(params[:liquor_license])
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
    if params[:liquor_license][:state_id]
      @state_first = GeoinfoState.find(params[:liquor_license][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first

    end
    respond_to do |format|
      if @liquor_license.save
        format.html { redirect_to(@liquor_license, :notice => 'Liquor license was successfully created.') }
        format.xml  { render :xml => @liquor_license, :status => :created, :location => @liquor_license }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @liquor_license.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /liquor_licenses/1
  # PUT /liquor_licenses/1.xml
  def update
    @liquor_license = LiquorLicense.find(params[:id])

    respond_to do |format|
      if @liquor_license.update_attributes(params[:liquor_license])
        format.html { redirect_to(@liquor_license, :notice => 'Liquor license was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @liquor_license.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /liquor_licenses/1
  # DELETE /liquor_licenses/1.xml
  def destroy
    @liquor_license = LiquorLicense.find(params[:id])
    @liquor_license.destroy

    respond_to do |format|
      format.html { redirect_to(liquor_licenses_url) }
      format.xml  { head :ok }
    end
  end
  def paypal_request

    pay_request = PaypalAdaptive::Request.new
    @liquor_license = LiquorLicense.find(params[:id])  

    data = {
      "returnUrl" => "http://localhost:3000", 
      "requestEnvelope" => {"errorLanguage" => "en_US"},
      "currencyCode"=>"USD",  
      "receiverList"=>{"receiver"=>[{"email"=>"test1_1299037760_per@gmail.com", "amount"=>"10.00"}]},
      "cancelUrl"=>"http://localhost:3000",
      "actionType"=>"PAY",
      "ipnNotificationUrl"=>"http://localhost:3000"
    }

    pay_response = pay_request.pay(data)

    if pay_response.success?
      redirect_to pay_response.approve_paypal_payment_url
    else
      puts pay_response.errors.first['message']
      redirect_to failed_payment_url
    end

  end

  def get_for_sale
    query_string = ""
    conditions = {}
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
   
    logger.info 'aaaa'
    if params[:liquor_license] and params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
      @state_first = GeoinfoState.find(params[:liquor_license][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
 
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        logger.info 'aa'
        query_string = query_string + " AND title LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip + "%"
      end
      if params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
        query_string = query_string + " AND state_id = :state_id"  
        conditions[:state_id] = params[:liquor_license][:state_id]
      end
      if params[:liquor_license][:city_id] != nil and params[:liquor_license][:city_id] != ''
        query_string = query_string + " AND city_id = :city_id"  
        conditions[:city_id] = params[:liquor_license][:city_id]
      end
      if params[:liquor_license][:license_type_id] != nil and params[:liquor_license][:license_type_id] != ''
        logger.info 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        query_string = query_string + " AND license_type_id = :license_type_id"  
        conditions[:license_type_id] = params[:liquor_license][:license_type_id]
      end
    end
    conditions[:today] = Date.today()
    conditions[:purpose] = 'Buy'
    conditions[:username] = session[:user_id]
    result = LiquorLicense.joins(:user).where("from_host IS NULL AND expiration_date >= :today AND purpose = :purpose AND users.username != :username" + query_string, conditions).find :all, :order => sort_order
    @liquor_licenses = result.paginate(:page => params[:page] ,:per_page => 1)
  end
  def get_for_buy
      
    query_string = ""
    conditions = {}
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
       
    if params[:liquor_license] and params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
      @state_first = GeoinfoState.find(params[:liquor_license][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        logger.info 'ba gia'
        query_string = query_string + " AND title LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip + "%"
      end
      if params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
        query_string = query_string + " AND state_id = :state_id"  
        conditions[:state_id] = params[:liquor_license][:state_id]
      end
      if params[:liquor_license][:city_id] != nil and params[:liquor_license][:city_id] != ''
        query_string = query_string + " AND city_id = :city_id"  
        conditions[:city_id] = params[:liquor_license][:city_id]
      end
      logger.info params[:liquor_license][:price_min]
      if params[:liquor_license][:price_min] != nil and params[:liquor_license][:price_min] != ''
        logger.info 'b'
        query_string = query_string + " AND price >= :price_min"  
        conditions[:price_min] = params[:liquor_license][:price_min]
      end
      if params[:liquor_license][:price_max] != nil and params[:liquor_license][:price_max] != ''
        query_string = query_string + " AND price <= :price_max"  
        conditions[:price_max] = params[:liquor_license][:price_max]
      end
      if params[:liquor_license][:license_type_id] != nil and params[:liquor_license][:license_type_id] != ''
 
        query_string = query_string + " AND license_type_id = :license_type_id"  
        conditions[:license_type_id] = params[:liquor_license][:license_type_id]
      end
    end
    conditions[:today] = Date.today()
    conditions[:purpose] = 'Sell'
     @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    conditions[:user_id] = @valid_user.id
    result = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) AND purpose = :purpose AND (user_id != :user_id or user_id IS NULL)" + query_string, conditions).find :all, :order => sort_order
    @liquor_licenses = result.paginate(:page => params[:page] ,:per_page => 30)
  end
  def get_for_both
    query_string = ""
    conditions = {}
    @state_first = GeoinfoState.find(:first, :order => 'name asc')
    logger.info params[:liquor_license] 
    if params[:liquor_license] and params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
      @state_first = GeoinfoState.find(params[:liquor_license][:state_id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '0').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        query_string = query_string + " AND title LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip + "%"
      end
      if params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
        query_string = query_string + " AND state_id = :state_id"  
        conditions[:state_id] = params[:liquor_license][:state_id]
      end
      if params[:liquor_license][:city_id] != nil and params[:liquor_license][:city_id] != ''
        query_string = query_string + " AND city_id = :city_id"  
        conditions[:city_id] = params[:liquor_license][:city_id]
      end
      if params[:liquor_license][:price_min] != nil and params[:liquor_license][:price_min] != ''
        query_string = query_string + " AND price >= :price_min"  
        conditions[:price_min] = params[:liquor_license][:price_min].to_i
      end
      if params[:liquor_license][:price_max] != nil and params[:liquor_license][:price_max] != ''
        query_string = query_string + " AND price <= :price_max"  
        conditions[:price_max] = params[:liquor_license][:price_max].to_i
      end
      if params[:liquor_license][:license_type_id] != nil and params[:liquor_license][:license_type_id] != ''
 
        query_string = query_string + " AND license_type_id = :license_type_id"  
        conditions[:license_type_id] = params[:liquor_license][:license_type_id]
      end
    end
    conditions[:today] = Date.today()
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    conditions[:user_id] = @valid_user.id
    result = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) AND (user_id != :user_id or user_id IS NULL)" + query_string, conditions).find :all, :order => sort_order
    @liquor_licenses = result.paginate(:page => params[:page] ,:per_page => 1)
  end
  def get_cities
    cities = []
    cities = GeoinfoCity.find(:all, :conditions =>{:state_id => params[:id]},  :order => 'name asc')
    logger.info 'ba giaaaaaa'
    logger.info params[:id]
    logger.info render :json => cities
  end
  def get_my_auction
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @liquor_license_auctions = []
    if @valid_user
    result = LiquorLicenseAuction.where(:bidder_id =>  @valid_user.id)
    @liquor_license_auctions = result.paginate(:page => params[:page] ,:per_page => 1)
    end
  end
  def accept
    liquor_license_auction = []
    logger.info params
    liquor_license_auction = LiquorLicenseAuction.find(params[:id])
    liquor_license_auction.status = true
    liquor_license_auction.save
    logger.info 'aaaaafffffffffffffffffffffffff'
    render :json => liquor_license_auction
  end
end
