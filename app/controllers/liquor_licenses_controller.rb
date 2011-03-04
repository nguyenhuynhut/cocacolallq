require 'geoinfo'
require 'nokogiri'
require 'open-uri'
class LiquorLicensesController < ApplicationController
  # GET /liquor_licenses
  # GET /liquor_licenses.xml
  def index
    @liquor_licenses = LiquorLicense.joins(:user).where("users.username != :username", {:username => session[:user_id]})
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @liquor_licenses }
    end
  end

  # GET /liquor_licenses/1
  # GET /liquor_licenses/1.xml
  def show
    @liquor_license = LiquorLicense.find(params[:id])

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
  end

  # POST /liquor_licenses
  # POST /liquor_licenses.xml
  def create
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @liquor_license = @valid_user.liquor_licenses.create(params[:liquor_license])

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
  def get_craigslist
    # Get a Nokogiri::HTML:Document for the page we’re interested in...
    
    doc = Nokogiri::HTML(open('http://detroit.craigslist.org/search/sss?query=liquor+license&srchType=T&minAsk=&maxAsk='))
    doc.xpath('//p[@class="row"]').each do |link|
      index = link.content.index('-') - 1
      title = ''
      url = ''
      location = ''
      price = 0
      logger.info link.content[10..index]
      created_at = Date.parse(link.content[10..index] + Date.today().year().to_s )
      #logger.info Date.strptime(link.content[10..index] + Date.today().year().to_s ,"%b %d %yyyy")
      if link.at('a')
        index = link.at('a').text.index('-') - 1
        title = link.at('a').text[0, index]
        url = link.at('a')['href']
      end
      if link.at('font')
        begin_index = link.at('font').text.index('(') + 1
        end_index = link.at('font').text.index(')') - 1
        location = link.at('font').text[begin_index..end_index]
      end
      if link.content.split('$').length == 2
        index = link.content.split('$')[1].index(' ') - 1
        price = link.content.split('$')[1][0..index].to_i
      end
      liquor_license = LiquorLicense.where(:title => title , :url => url , :location => location , :price => price).first
      if liquor_license == nil
        liquor_license = LiquorLicense.new(:title => title , :url => url , :location => location , :price => price, :from_host => 'craigslist', :purpose => 'None', :created_at => created_at , :updated_at => created_at)
        liquor_license.save
      end
    end
    @liquor_licenses = LiquorLicense.where(:from_host => 'craigslist')
  end
  def get_for_sale
    query_string = ""
    conditions = {}
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        logger.info 'aa'
        query_string = " AND title LIKE :title"  
        conditions[:title] = params[:liquor_license][:title]
      end
      if params[:liquor_license][:state] != nil and params[:liquor_license][:state] != ''
        query_string = " AND state = :state"  
        conditions[:state] = params[:liquor_license][:state]
      end
      if params[:liquor_license][:city] != nil and params[:liquor_license][:city] != ''
        query_string = " AND city LIKE :city"  
        conditions[:city] = params[:liquor_license][:city]
      end

    end
    conditions[:today] = Date.today()
    conditions[:purpose] = 'Buy'
    conditions[:username] = session[:user_id]
 
    
    @liquor_licenses = LiquorLicense.joins(:user).where("from_host IS NULL AND expiration_date >= :today AND purpose = :purpose AND users.username != :username" + query_string, conditions)
    logger.info @liquor_licenses
  end
  def get_for_buy
      
    query_string = ""
    conditions = {}
    logger.info params[:liquor_license]
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        query_string = " AND title LIKE :title"  
        conditions[:title] = params[:liquor_license][:title]
      end
      if params[:liquor_license][:state] != nil and params[:liquor_license][:state] != ''
        query_string = " AND state = :state"  
        conditions[:state] = params[:liquor_license][:state]
      end
      if params[:liquor_license][:city] != nil and params[:liquor_license][:city] != ''
        query_string = " AND city LIKE :city"  
        conditions[:city] = params[:liquor_license][:city]
      end
      logger.info params[:liquor_license][:price_min]
      if params[:liquor_license][:price_min] != nil and params[:liquor_license][:price_min] != ''
        logger.info 'b'
        query_string = " AND price >= :price_min"  
        conditions[:price_min] = params[:liquor_license][:price_min]
      end
      if params[:liquor_license][:price_max] != nil and params[:liquor_license][:price_max] != ''
        query_string = " AND price <= :price_max"  
        conditions[:price_max] = params[:liquor_license][:price_max]
      end
    end
    conditions[:today] = Date.today()
    conditions[:purpose] = 'Sell'
    conditions[:username] = session[:user_id]
 
    
    @liquor_licenses = LiquorLicense.joins(:user).where("from_host IS NULL AND expiration_date >= :today AND purpose = :purpose AND users.username != :username" + query_string, conditions)
    logger.info @liquor_licenses
    logger.info @liquor_licenses
  end
  def get_for_both
    query_string = ""
    conditions = {}
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        query_string = " AND title LIKE :title"  
        conditions[:title] = params[:liquor_license][:title]
      end
      if params[:liquor_license][:state] != nil and params[:liquor_license][:state] != ''
        query_string = " AND state = :state"  
        conditions[:state] = params[:liquor_license][:state]
      end
      if params[:liquor_license][:city] != nil and params[:liquor_license][:city] != ''
        query_string = " AND city LIKE :city"  
        conditions[:city] = params[:liquor_license][:city]
      end
      if params[:liquor_license][:price_min] != nil and params[:liquor_license][:price_min] != ''
        query_string = " AND :price >= :price"  
        conditions[:price] = params[:liquor_license][:price_min].to_i
      end
      if params[:liquor_license][:price_max] != nil and params[:liquor_license][:price_max] != ''
        query_string = " AND price <= :price"  
        conditions[:price] = params[:liquor_license][:price_max].to_i
      end
    end
    conditions[:today] = Date.today()
    conditions[:username] = session[:user_id]
 
    
    @liquor_licenses = LiquorLicense.joins(:user).where("from_host IS NULL AND expiration_date >= :today AND users.username != :username" + query_string, conditions)
    logger.info @liquor_licenses
  end
end
