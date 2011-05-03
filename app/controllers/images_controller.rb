class ImagesController < ApplicationController
  
  def new
  end

  def edit
  	# This basically gets all the pictures and meta data so that the user can select 1 or more.

  	# Needs refactoring
    #
    @picturesandmeta = Pictureandmeta.all
    @kind = Kind.find(params[:kind_id])
    Rails.logger.info("Kind: #{@kind.inspect}")
  end
  
  def update
    kind = Kind.find(params[:kind_id])
    #Rails.logger.info("PARAMS: #{params[:images].inspect}")
    kind.add_images(params[:images])
    if kind.update_attributes!
      flash[:notice] = "Successfully changed pictures."
      redirect_to kinds_url
    else
      render :action => 'edit'
    end
  end
  
end