require 'yaml'
require 'geoinfo'
require 'nokogiri'
require 'open-uri'
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
  def User.check_criteria
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
  def User.sendmail_criteria_activity
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
  def User.check_bid
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
  def User.sendmail_bid_activity
    subject = 'Bid Higher'
    bid_activities = BidActivity.find(:all)
    bid_activities.each do |bid_activity|
      if bid_activity.status == false
        UserMailer.bid_activity( subject, bid_activity).deliver
      end
    end

  end
  def User.get_craigslist
    # Get a Nokogiri::HTML:Document for the page we’re interested in...
    
      
    doc = Nokogiri::HTML(open('http://www.craigslist.org/about/sites'))
    doc.xpath('//li/a').each do |link|
      state_id = nil
      city_id = nil
      location = []
      place = link.text
      location << place.strip 
      if location[0].include? '-' 
        location = location[0].split(/-/)
      end
      if location[0].include? '/'
        location = location[0].split(/\//)
      end
      for i in 0..(location.length - 1)
        conditions = {}
        conditions[:name] = location[i]
        city_result = GeoinfoCity.where("name LIKE :name", conditions).find(:all, :order => "population_2000 desc").first
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
            if link_detail.at('a').text
              index = link_detail.at('a').text.index('-') - 1
              title = link_detail.at('a').text[0, index]
            end
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
  end
  def User.import_data

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
  def User.delete_licenses
    @liquor_licenses = LiquorLicense.find(:all)
    @liquor_licenses.each do |liquor_license|
      liquor_license.delete
    end
  end
end
