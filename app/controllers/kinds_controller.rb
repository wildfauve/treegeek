class KindsController < ApplicationController

  uses_tiny_mce

  def index
    #
    # GET /kinds
    #params[:page].nil? ? @page = 1 : @page = params[:page].to_i
    #@kinds = Kind.all.paginate(:page => @page, :per_page => Kind.page_limit)

    @kinds = Kind.all.page params[:page]

    respond_to do |format|
      format.html
      format.xml {render :xml => @kinds}
    end
    
  end
  
  def show
    #
    # GET kind
    # 
    @kind = Kind.find(params[:id])
  end
  
  def new
    #
    @kind = Kind.new
  end
  
  def create
    #
    # POST kinds
    #
    @kind = Kind.new(params[:kind])
    if @kind.save
      flash[:notice] = "Successfully created kind."
      redirect_to @kind
    else
      render :action => 'new'
    end
  end
  
  def edit
    @kind = Kind.find(params[:id])
  end
  
  def update
    #
    # PUTS Kind
    #
    @kind = Kind.find(params[:id])
    respond_to do |format|
      if @kind.update_attributes(params[:kind])
        flash[:notice] = "Successfully updated kind."
        format.html {redirect_to @kind}
        format.xml {head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml { render :xml => @kind.errors, :status => :unprocessable_entity}
      end  
    end
    
  end
  
  def destroy
    #
    # DELETE Kind
    #
    @kind = Kind.find(params[:id])
    @kind.destroy
    flash[:notice] = "Successfully destroyed kind."
    redirect_to kinds_url
  end

  # Member route methods here

  def images
    @picturesandmeta = Pictureandmeta.all
    @kind = Kind.find(params[:kind_id])
    Rails.logger.info("Kind: #{@kind.inspect}")
  end

  # Collection Route methods here

  # This is basically an algorithm resource GET kinds/search
  def search
    # if the user has selected to clear the search, or there is no search params, start from the top
    if params[:clear] || params[:q] == ""
      Rails.logger.info("Kind: #{params.inspect}")
      redirect_to kinds_path
    else  
      @kinds = Kind.search(params[:q]).page params[:page]
      #@page = 1
      render :index
    end
  end

end