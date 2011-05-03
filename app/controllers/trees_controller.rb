class TreesController < ApplicationController


  def index
    @trees = Tree.all.page params[:page]
  end

  # GET /trees/new
  # path: new_tree_path
  def new
    @tree = Tree.new
  end

  # POST /trees
  def create
    #Rails.logger.info(">>>Tree Controller>>CREATE: #{params.inspect}")
    @tree = Tree.new(params[:tree])
    @tree.add_external_refs(params[:kind], params[:dimensions])
    if @tree.save
      flash[:notice] = "Successfully created tree."
      redirect_to @tree
    else
      render :action => 'new'
    end
  end

  # GET /trees/{id}
  def show
    @tree = Tree.find(params[:id])
  end

  # GET /trees/edit
  def edit
    @tree = Tree.find(params[:id])
  end

  # PUT /trees/{id}
  def update
    @tree = Tree.find(params[:id])
    #
    #Rails.logger.info(">>>Update Tree: #{params.inspect} >> #{params[:dimensions]} >>> #{dim.inspect}")
    @tree.add_external_refs(params[:kind], params[:dimensions])
    respond_to do |format|
      if @tree.update_attributes(params[:tree])
        flash[:notice] = "Successfully updated tree."
        format.html {redirect_to @tree}
      else
        format.html { render :action => 'edit' }
      end
    end  
  end
  
  def destroy
     #
     # DELETE Tree
     #
     @tree = Tree.find(params[:id])
     # remove references in other models
    @tree.remove_references(:scope => :all)
    respond_to do |format|
      if @tree.destroy
         flash[:notice] = "Successfully destroyed tree."
         format.html {redirect_to trees_url}
         format.js {render :nothing => true}
      else
        flash[:notice] = "Couldn't remove Tree"
        render :action => 'show'
      end
    end
   end

  # Collection Route methods here

    # This is basically an algorithm resource GET kinds/search
  def search
    # if the user has selected to clear the search, or there is no search params, start from the top
    if params[:clear] || params[:q] == ""
      redirect_to trees_path
    else  
      @trees = Tree.search(params[:q]).page params[:page]
      Rails.logger.info(">>>Tree Controller>>SEARCG: #{@trees.count}")
      render :index
    end
  end



end