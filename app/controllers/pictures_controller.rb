class PicturesController < ApplicationController
  
  # The picture controller deals with the CRUD of images and their metadata.  These images can be anything, but are 
  # generally Tree images.
  
  
  def index
    # TODO Paging wont work because PictandMeta is not an ActiveModel
    @tree_id = params[:assigned_pics_tree].to_s if params[:assigned_pics_tree]
    @picturesandmeta = Pictureandmeta.all
  end
  
  def show
    @pictureandmeta = Pictureandmeta.find(params)
    #render :text => @picmeta.to_yaml
  end
  
  def new
    session[:assigned_pics_tree] = {:tree => [params[:assigned_pics_tree].to_s]} if params[:assigned_pics_tree]
    @pictureandmeta = Pictureandmeta.new
  end
  
  def edit
    @pictureandmeta = Pictureandmeta.find(params)
  end
  
  def update
    @pictureandmeta = Pictureandmeta.find(params)
    if @pictureandmeta.update(params)
      flash[:notice] = "Successfully updated Picture."
      redirect_to pictures_url
    else
      render :action => 'edit'
    end
  end
  
  def create
    params[:pictureandmeta][:picmeta][:assigned_pics] = session[:assigned_pics_tree] if session[:assigned_pics_tree]
    session[:assigned_pics_tree] = nil
    if Pictureandmeta.create(params)
      flash[:notice] = "Successfully created Picture."
      redirect_to pictures_url
    else
      flash[:notice] = "Error updating the Picture and or meta"
      render :action => 'new'
    end
  end
  
  def destroy
    @pictureandmeta = Pictureandmeta.find(params)
    if @pictureandmeta.destroy
      flash[:notice] = "Successfully destroyed picture."
      redirect_to pictures_url
    else 
      flash[:notice] = "Error in the delete"
      redirect_to pictures_url
     end
  end
  
  #  Collection resource methods here
  
  # gets involved from index when the user has requested to associate pictures with specific trees
  # uses a hidden field called selected_tree to hold the tree id.
  def selected_trees
    Rails.logger.info(">>>Selected Tree #{params.inspect}")
    if Pictureandmeta.add_assigned_pics(params['selected_tree'], params['add_to'])
      flash[:notice] = "Successfully added sslected pictures."
    else
      flash[:notice] = "Pictures not added due to error."
    end
    redirect_to :controller => 'trees', :action => 'show', :id => params['selected_tree']
  end
  

  # A PUT Resource that is called, currently, to remove a tree reference from a Picture.
  # IN: id of picture, id of tree
  def assignedtrees
    @pictureandmeta = Pictureandmeta.find(params)
    @pictureandmeta.delete_assigned_pics(params[:tree])
    redirect_to :controller => 'trees', :action => 'show', :id => params[:tree]
  end

  # This is basically an algorithm resource GET kinds/search
  def search
    # if the user has selected to clear the search, or there is no search params, start from the top
    Rails.logger.info("Pic Search: #{params.inspect}")
    if params[:clear] || params[:q] == ""
      redirect_to pictures_path
    else  
      @picturesandmeta = Pictureandmeta.search(params[:q])
      #@page = 1
      render :index
    end
  end



end