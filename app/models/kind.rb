 class Kind
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search

  paginates_per 20

  validates_uniqueness_of :botanic_name
  
  field :family, :type => String
  field :botanic_name, :type => String, :required => true
  field :english_name, :type => String
  field :maori_name, :type => String
  field :description, :type => String
  field :icon, :type => Fixnum

  references_one :tree

  
  # From mongoid_search gem
  # search creates an array of stemmed tags in each instance of a Kind, for keyword searching
  # plus provides a search method
  search_in :botanic_name, :english_name, :maori_name

  
  # Set the default page limit for kinds.
  def self.page_limit
    15
  end
  
  # 
  # Note that this replaces Pictures entirely with the non "0" keys.
  # Will need refactoring when dealing with large number of images (or multi-submits)
  #     
  def add_images(selection)    
      #@pictures = [selection.delete_if {|k, v| v == "0"}.keys, @pictures].flatten.compact.uniq
      @pictures = selection.delete_if {|k, v| v == "0"}.keys
      #Rails.logger.info(">>>Picture after add: #{self.pictures.inspect}")
  end
  
  
  def get_one_image_random
    # Sample picks one of the elements from the array for display.  If there is no image, return nil
    self.pictures != nil ? Pictureandmeta.find({:id => self.pictures.sample.to_i}) : nil
  end

  def get_icon
    # Gets the icon image
    #@icon.blank? ? nil : Pictureandmeta.find({:id => @icon.to_i})
    #Rails.logger.info(">>>Get Icon: #{self.inspect}, Botanic: #{self.botanic_name}, ICON: #{self.icon}")
    Pictureandmeta.find({:id => self.icon})
  end
  
  def image_checked?(pic_id)
    # determine if the picture id supplied is checked in the kind
    #Rails.logger.info(">>>Image_Checked: #{pictures.inspect}, #{pic_id}")
    if self.pictures != nil
      self.pictures.find {|p| p == pic_id } != nil ? true : false
    else
      false
    end
  end
  
end