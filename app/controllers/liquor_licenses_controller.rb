require 'geoinfo'
require 'nokogiri'
require 'open-uri'
require "sortable_table"
class LiquorLicensesController < ApplicationController
  # GET /liquor_licenses
  # GET /liquor_licenses.xml
  sortable_attributes :title , :expiration_date, :price
  def index
    result = LiquorLicense.joins(:user).where("users.username = :username", {:username => session[:user_id]})
    logger.info session[:user_id]
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
    @liquor_license_auction =LiquorLicenseAuction.where(:liquor_license_id => params[:id], :bidder_id =>  @valid_user.id).first
    if params[:auction] and params[:auction][:bid] != '' and params[:auction][:bid].to_f > 0
      if  @liquor_license.user
        recipient = @liquor_license.user.email
        subject = "Bid Your Liquor License"
        message = params[:auction][:message]
        if recipient
          UserMailer.bid(recipient, subject, @valid_user, message, @liquor_license, params[:auction][:bid]).deliver
        end
      end
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
    @liquor_license_auctions = LiquorLicenseAuction.where(:liquor_license_id  => params[:id]).find :all, :order => 'price desc'
    logger.info @liquor_license_auctions
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @liquor_license }
    end
  end

  # GET /liquor_licenses/new
  # GET /liquor_licenses/new.xml
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
    @liquor_license = LiquorLicense.new
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @cities_first = GeoinfoCity.where(:state_id => '2').find :all, :order => "name asc"
    @selected_city = nil
    logger.info @cities_first
    if @liquor_license.city_id
      @selected_city = GeoinfoCity.find(@liquor_license.city_id)

    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @liquor_license }
    end
  end

  # GET /liquor_licenses/1/edit
  def edit
    @liquor_license = LiquorLicense.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.id != @liquor_license.user_id
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    @state_first = GeoinfoState.find(@liquor_license.state_id)
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
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
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
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
  def delete_record
    @liquor_license = LiquorLicense.find(params[:id])
    @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    if session[:user_id] != nil and session[:user_id] != ''
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])

      if @valid_user.id != @liquor_license.user_id
        flash[:error] = "You don't have access to this section." 
        redirect_to '/'
        return
      end 
      
    else
      flash[:error] = "You don't have access to this section." 
      redirect_to '/'
      return
    end
    @liquor_license.destroy
    redirect_to(request.env["HTTP_REFERER"])

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
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
 
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        logger.info 'aa'
        query_string = query_string + " AND UPPER(title) LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip.upcase + "%"
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
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        logger.info 'ba gia'
        query_string = query_string + " AND UPPER(title) LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip.upcase + "%"
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
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
        query_string = query_string + " AND UPPER(title) LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip.upcase + "%"
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
  def get_craigslist
    
    doc = Nokogiri::HTML(open('http://www.craigslist.org/about/sites'))
    doc.xpath('//li/a').each do |link|
      state_id = nil
      city_id = nil
      location = []
      logger.info link['href']
      place = link.text
      location << place.strip 
      if location[0].include? '-' 
        location = location[0].split(/-/)
      end
      if location[0].include? '/'
        location = location[0].split(/\//)
      end
      logger.info location
      for i in 0..(location.length - 1)
        conditions = {}
        conditions[:name] = location[i]
        city_result = GeoinfoCity.where("name LIKE :name", conditions).find(:all, :order => "population_2000 desc").first
        logger.info city_result ? city_result.name : ''
        if city_result 
          state_result = GeoinfoState.find(city_result.state_id)
          if state_result
            state_id = city_result.state_id
          end
          city_id = city_result.id
        end        
        doc_detail = Nokogiri::HTML(open(link['href'] + '/search/sss?query=liquor+license&srchType=T&minAsk=&maxAsk='))
        doc_detail.xpath('//p[@class="row"]').each do |link_detail|
          index = link_detail.content.index('-') - 1
          title = nil
          url = nil
          email = nil

          license_type_id = nil

          price = 0
          created_at = Date.parse(link_detail.content[10..index] + Date.today().year().to_s )
          #logger.info Date.strptime(link.content[10..index] + Date.today().year().to_s ,"%b %d %yyyy")
          if link_detail.at('a')
            index = link_detail.at('a').text.index('-') - 1
            title = link_detail.at('a').text[0, index]
            url = link_detail.at('a')['href']
            doc_detail_more = Nokogiri::HTML(open(url))
            doc_detail_more.xpath('//a').each do |link_detail_more|
              if link_detail_more.text.include? '@craigslist.org'
                email = link_detail_more.text
              end
            end
          end
          if link_detail.content.split('$').length == 2
            index = link_detail.content.split('$')[1].index(' ') - 1
            price = link_detail.content.split('$')[1][0..index].to_i
          end
          liquor_license = LiquorLicense.where(:title => title , :price => price, :from_host => 'craigslist', :purpose => 'Sell',  :state_id => state_id , :city_id => city_id).first
          if liquor_license == nil
            liquor_license = LiquorLicense.new(:title => title , :price => price, :from_host => 'craigslist', :purpose => 'Sell', :created_at => created_at , :updated_at => created_at, :state_id => state_id , :city_id => city_id)
            liquor_license.save
          end
        end
      end 
    end
    @liquor_licenses = LiquorLicense.where(:from_host => 'craigslist')
  end
  def backup
    # Get a Nokogiri::HTML:Document for the page we’re interested in...
    
    doc = Nokogiri::HTML(open('http://detroit.craigslist.org/search/sss?query=liquor+license&srchType=T&minAsk=&maxAsk='))
    doc.xpath('//p[@class="row"]').each do |link|
      index = link.content.index('-') - 1
      title = nil
      url = nil
      email = nil
      state_id = nil
      state = nil
      license_type_id = nil
      city_id = nil
      city = nil
      price = 0
      created_at = Date.parse(link.content[10..index] + Date.today().year().to_s )
      #logger.info Date.strptime(link.content[10..index] + Date.today().year().to_s ,"%b %d %yyyy")
      if link.at('a')
        index = link.at('a').text.index('-') - 1
        title = link.at('a').text[0, index]
        url = link.at('a')['href']
        doc_detail = Nokogiri::HTML(open(url))
        doc_detail.xpath('//a').each do |link_detail|
          if link_detail.text.include? '@craigslist.org'
            email = link_detail.text
          end
        end
      end
      if link.at('font')
        begin_index = link.at('font').text.index('(') + 1
        end_index = link.at('font').text.index(')') - 1
        location = link.at('font').text[begin_index..end_index]
        location = location.strip   
        location = location.gsub(/[&,-\/]/, ' ')  
        array_location = location.split
        for i in 0..(array_location.length - 1)
          array_location[i] = "%" + array_location[i] + "%"
          conditions = {}
          conditions[:name] = array_location[i]
          state_result = GeoinfoState.where("name LIKE :name", conditions).find(:all, :order => "name asc").first
          if state 
            if state_result
              state = state_result
              
            end  
          else
            state = state_result
          end
                
        end     
        
        for i in 0..(array_location.length - 1)
          conditions = {}
          conditions[:name] = array_location[i]
          city_result = GeoinfoCity.where("name LIKE :name", conditions).find(:all, :order => "population_2000 desc").first
          if city 
            if city_result
              if city_result.population_2000 > city.population_2000
                city = city_result
              end
            end  
          else
            city = city_result
          end
                
        end
        if state == nil
          if city != nil
            city_id = city.id
            state_id = city.state_id
          end
        else
          if city 
            if city.state_id == state.id
              city_id = city.id
              state_id = city.state_id
            else
              state_id = state.id
              city_id = nil
            end 
          else 
            city_id = nil
            state_id = state.id
          end
        end

      end
      if link.content.split('$').length == 2
        index = link.content.split('$')[1].index(' ') - 1
        price = link.content.split('$')[1][0..index].to_i
      end
      liquor_license = LiquorLicense.where(:title => title , :price => price).first
      if liquor_license == nil
        liquor_license = LiquorLicense.new(:title => title , :price => price, :from_host => 'craigslist', :purpose => 'Sell', :created_at => created_at , :updated_at => created_at, :state_id => state_id , :city_id => city_id)
        liquor_license.save
      end
    end
    @liquor_licenses = LiquorLicense.where(:from_host => 'craigslist')
  end
end
