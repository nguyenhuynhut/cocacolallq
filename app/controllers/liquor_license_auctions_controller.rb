class LiquorLicenseAuctionsController < ApplicationController
  # GET /liquor_license_auctions
  # GET /liquor_license_auctions.xml
    # Check that the user has the right authorization to access clients.
  before_filter :user_not_authorized
  def index
    @liquor_license_auctions = LiquorLicenseAuction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @liquor_license_auctions }
    end
  end

  # GET /liquor_license_auctions/1
  # GET /liquor_license_auctions/1.xml
  def show
    @liquor_license_auction = LiquorLicenseAuction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @liquor_license_auction }
    end
  end

  # GET /liquor_license_auctions/new
  # GET /liquor_license_auctions/new.xml
  def new
    @liquor_license_auction = LiquorLicenseAuction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @liquor_license_auction }
    end
  end

  # GET /liquor_license_auctions/1/edit
  def edit
    @liquor_license_auction = LiquorLicenseAuction.find(params[:id])
  end

  # POST /liquor_license_auctions
  # POST /liquor_license_auctions.xml
  def create
    @liquor_license_auction = LiquorLicenseAuction.new(params[:liquor_license_auction])

    respond_to do |format|
      if @liquor_license_auction.save
        format.html { redirect_to(@liquor_license_auction, :notice => 'Liquor license auction was successfully created.') }
        format.xml  { render :xml => @liquor_license_auction, :status => :created, :location => @liquor_license_auction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @liquor_license_auction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /liquor_license_auctions/1
  # PUT /liquor_license_auctions/1.xml
  def update
    @liquor_license_auction = LiquorLicenseAuction.find(params[:id])

    respond_to do |format|
      if @liquor_license_auction.update_attributes(params[:liquor_license_auction])
        format.html { redirect_to(@liquor_license_auction, :notice => 'Liquor license auction was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @liquor_license_auction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /liquor_license_auctions/1
  # DELETE /liquor_license_auctions/1.xml
  def destroy
    @liquor_license_auction = LiquorLicenseAuction.find(params[:id])
    @liquor_license_auction.destroy

    respond_to do |format|
      format.html { redirect_to(liquor_license_auctions_url) }
      format.xml  { head :ok }
    end
  end
  private

  def user_not_authorized
    
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
  end
end
