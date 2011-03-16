require 'geoinfo'
class HomeController < ApplicationController
  sortable_attributes :title  , :expiration_date, :price
  def index
    if session[:user_id]
      @valid_user = User.find(:first, :conditions => ["username = ? ", session[:user_id]])
    end
    @states = GeoinfoState.find(:all, :order => 'name asc')
    conditions = {}

    
    conditions[:today] = Date.today()
    conditions[:before] = Date.today() - 60
    result = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) AND  created_at >= :before", conditions).find :all, :order => sort_order, :limit => 1000
    @liquor_licenses = result.paginate(:page => params[:page] ,:per_page => 20)
  end
  def search
    query_string = ""
    conditions = {}
    if params[:liquor_license] and params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
      @state_first = GeoinfoState.find(params[:liquor_license][:state_id])
    end
    logger.info params
    if params[:search] and params[:search][:id]
      @state_first = GeoinfoState.find(params[:search][:id])
    end
    @cities_first = GeoinfoCity.where(:state_id => @state_first ? @state_first.id : '2').find :all, :order => "name asc"
    @selected_city = nil
    if params[:liquor_license] and params[:liquor_license][:city_id] 
      @selected_city = GeoinfoCity.where(:id => params[:liquor_license][:city_id]).first
    end
     if params[:search] and params[:search][:id]
      logger.info 'aaaaaaaaaaaasaa'
      query_string = query_string + " AND state_id = :state_id"  
      conditions[:state_id] = params[:search][:id]
    end
    if params[:liquor_license]
      if params[:liquor_license][:title] != nil and params[:liquor_license][:title] != ''
         logger.info 'aaaaaaabbbbbbbbbbbaaaaaaa'
        query_string = query_string + " AND UPPER(title) LIKE :title"  
        conditions[:title] = "%" + params[:liquor_license][:title].strip.upcase + "%"
      end
      if params[:liquor_license][:state_id] != nil and params[:liquor_license][:state_id] != ''
        query_string = query_string + " AND state_id = :state_id"  
        conditions[:state_id] = params[:liquor_license][:state_id]
      end
      if params[:liquor_license][:city_id] != nil and params[:liquor_license][:city_id] != ''
         logger.info 'aaaaaaaaaaaccccccccccaaa'
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
    logger.info conditions
    result = LiquorLicense.where("(expiration_date >= :today OR expiration_date IS NULL) " + query_string , conditions).find :all, :order => sort_order
    logger.info 'buon boi'
    @liquor_licenses = result.paginate(:page => params[:page] ,:per_page => 20)
  end
end
