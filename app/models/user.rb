class User < ActiveRecord::Base

  validates :username , :kind ,:presence => true
  validates_uniqueness_of :email
  validates_uniqueness_of :username
  validates_length_of :username, :within => 5..50
  validates_length_of :password, :within => 5..50
  validates_confirmation_of :password 
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "must be valid"
  before_save :hash_password
  def hash_password
    if password_changed?
      self.password = Digest::SHA1.hexdigest(password)
    end
  end
  has_many :liquor_licenses ,:dependent => :destroy
  has_one :user_detail, :dependent=> :destroy
  has_one :criteria, :dependent => :destroy
  has_many :criteria_activities, :dependent => :destroy
  has_many :liquor_license_auctions
  has_many :bid_activities
  def self.check_criteria
    @users = User.find(:all)
    @users.each do |user|
      result = []
      if user.criteria
        if user.kind == "Selling"
          conditions = {}
          conditions[:today] = Date.today()
          conditions[:purpose] = 'Buy'
          conditions[:user_id] = user.id
          conditions[:state_id] = user.criteria.state_id
          conditions[:city_id] = user.criteria.city_id
          conditions[:license_type_id] = user.criteria.license_type_id
          result_selling = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) AND purpose = :purpose AND (user_id != :user_id or user_id IS NULL) AND state_id = :state_id AND city_id = :city_id AND license_type_id = :license_type_id" , conditions)
          if result_selling
            result = result + result_selling
          end
        end
        if user.kind == "Buying"
          conditions = {}
          conditions[:today] = Date.today()
          conditions[:purpose] = 'Sell'
          conditions[:user_id] = user.id
          conditions[:state_id] = user.criteria.state_id
          conditions[:city_id] = user.criteria.city_id
          conditions[:license_type_id] = user.criteria.license_type_id
          result_buying = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) AND purpose = :purpose AND (user_id != :user_id or user_id IS NULL) AND state_id = :state_id AND city_id = :city_id AND license_type_id = :license_type_id" , conditions)
          if result_buying
            result = result + result_buying
          end
        end
        if user.kind == "Both"
          conditions = {}
          conditions[:today] = Date.today()
          conditions[:user_id] = user.id
          conditions[:state_id] = user.criteria.state_id
          conditions[:city_id] = user.criteria.city_id
          conditions[:license_type_id] = user.criteria.license_type_id
          result_both = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) AND (user_id != :user_id or user_id IS NULL) AND state_id = :state_id AND city_id = :city_id AND license_type_id = :license_type_id" , conditions)
          if result_both
            result = result + result_both
          end
        end

      end
      if result 
        result.each do |liquor_license_each|
          criteria_activity = CriteriaActivity.where(:liquor_license_id => liquor_license_each.id, :user_id => user.id).first
          if criteria_activity == nil
            criteria_activity = CriteriaActivity.new(:liquor_license_id => liquor_license_each.id, :user_id => user.id, :expiration_date => liquor_license_each.expiration_date, :status => false)
            criteria_activity.save()
          end
        end

      end
    end
    
  end
  def self.sendmail_criteria_activity
    @users = User.find(:all)
    subject = 'Your Criteria about Liquor License'
    @users.each do |user|
      check = false
      user.criteria_activities.each do |criteria_activity|
        if criteria_activity.status == false
          check = true
        end
      end
      if check == true
        UserMailer.criteria_activity( subject, user).deliver
      end
    end

  end
  def self.check_bid
    @users = User.find(:all)
    @users.each do |user|
      auctions = LiquorLicenseAuction.where(:bidder_id => user.id)
      auctions.each do |auction|
        conditions = {}
        conditions[:liquor_license_id] = auction.liquor_license_id
        liquor_license_auction = LiquorLicenseAuction.where(" liquor_license_id = :liquor_license_id" ,conditions).order("price desc").first
        if liquor_license_auction and liquor_license_auction.bidder_id != user.id
          conditions = {}
          conditions[:user_id] = user.id
          conditions[:liquor_license_auction_id] = liquor_license_auction.id
          bid_activity = BidActivity.where("user_id = :user_id AND liquor_license_auction_id = :liquor_license_auction_id" ,conditions).first
          if bid_activity == nil
            bid_activity = BidActivity.new(:user_id => user.id, :liquor_license_auction_id => liquor_license_auction.id, :status => false, :expiration_date => liquor_license_auction.liquor_license.expiration_date )
            bid_activity.save()
          end
        end
      end
    end
  end
  def self.sendmail_bid_activity
    subject = 'Bid Higher'
    bid_activities = BidActivity.find(:all)
    bid_activities.each do |bid_activity|
      if bid_activity.status == false
        UserMailer.bid_activity( subject, bid_activity).deliver
      end
    end

  end
    def self.get_craigslist
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
