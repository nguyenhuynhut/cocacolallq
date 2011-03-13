class LicenseTypesController < ApplicationController
  # GET /license_types
  # GET /license_types.xml
  def index
    @license_types = LicenseType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @license_types }
    end
  end

  # GET /license_types/1
  # GET /license_types/1.xml
  def show
    @license_type = LicenseType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @license_type }
    end
  end

  # GET /license_types/new
  # GET /license_types/new.xml
  def new
    @license_type = LicenseType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @license_type }
    end
  end

  # GET /license_types/1/edit
  def edit
    @license_type = LicenseType.find(params[:id])
  end

  # POST /license_types
  # POST /license_types.xml
  def create
    @license_type = LicenseType.new(params[:license_type])

    respond_to do |format|
      if @license_type.save
        format.html { redirect_to(@license_type, :notice => 'License type was successfully created.') }
        format.xml  { render :xml => @license_type, :status => :created, :location => @license_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @license_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /license_types/1
  # PUT /license_types/1.xml
  def update
    @license_type = LicenseType.find(params[:id])

    respond_to do |format|
      if @license_type.update_attributes(params[:license_type])
        format.html { redirect_to(@license_type, :notice => 'License type was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @license_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /license_types/1
  # DELETE /license_types/1.xml
  def destroy
    @license_type = LicenseType.find(params[:id])
    @license_type.destroy

    respond_to do |format|
      format.html { redirect_to(license_types_url) }
      format.xml  { head :ok }
    end
  end
end
