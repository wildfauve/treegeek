class Pictureandmeta

  class PicmetaError < StandardError; end

  # This is a proxy for our 2 models that deal with Pictures (the ActiveRecord paperclip model) and 
  # PicMeta (the non-ActiveRecord Mongomapper model)
  # which is a bit of a pain, but I couldn't find an easy way to put paperclip into Mongo, and I want everything else to be Mongo. 
  attr_accessor :picture, :meta
  
  def self.all(ids = [])
    if ids.empty?
      pictures = Picture.all
      metas = Picmeta.all
    else
      raise 
      pictures, metas = [], []
      ids.each do |id|
        pictures << Picture.find(id.to_i)
        metas << Picmeta.first(:ext_picture_id => id)
      end
    end
    normaliseall(pictures, metas)
  end
  
  def self.find(params)
    #
    # need to think about converting this to a find_by_id unless there are other use cases
    #
    Pictureandmeta.new(pic: Picture.find(params[:id]), meta: Picmeta.find(:first, :conditions => {:ext_picture_id => params[:id].to_s}))
    
  end

  # provide a collection of ids (in an array) from another model (e.g. a tree), and find the images with this as a tag
  # params: Array of tree_ids.to_s
  def self.find_by_assigned_ref_with_id(modelref, options={:with_pictures => true})
    # TODO: this only finds a tree at the moment
    # TODO: Probaby broken when there are more than 1 trees in the assigned tree
    # TODO: Bit of metaprog here; as can use the model's class name as the type
    metas = Picmeta.where('assignedrefs.ref' => modelref.id.to_s).and('assignedrefs.ref_type' => modelref.class.name.downcase)
    if options[:with_pictures]
      Rails.logger.info(">>>Find_by: #{metas.inspect}, #{metas.count}")
      pictures = []
      metas.each do |m|
        pic = Picture.find_by_id(m.ext_picture_id)
        pictures << pic if pic
        #Rails.logger.info(">>>Find_by_Process Metas: #{pic.inspect}, #{pictures.inspect}")
      end
      #Rails.logger.info(">>>Find_by: #{pictures.inspect}, #{metas.inspect}, #{metas.count}")
      normaliseall(pictures, metas)
    else
      metaarray = []
      metas.each do |m|
       metaarray << Pictureandmeta.new(meta: m)
      end
      metaarray 
    end
  end
  
  def self.create(params)
    # save the Picture
    # TODO: work out how to "roll back" the Picture save if Mongo save errors
    picture = Picture.create(params[:pictureandmeta][:picture])
    if picture
      picmeta = Picmeta.new(params[:pictureandmeta][:picmeta])
      picmeta.ext_picture_id = picture.id.to_s
      picmeta.tags = tag_ify(params[:pictureandmeta][:picmeta][:tags])
      picmeta.save ? true : false
    else
      false
    end
  end
  

  # The user can select multiple pictures to assign to a Tree
  # The list contains an array of picture ids
  def self.add_assigned_pics(tree_id, pic_list)
    metas = Picmeta.any_in('ext_picture_id' => pic_list)
    Rails.logger.info(">>>Add_Assigned_Pics: Treeid: #{tree_id}, <<pic list>> #{pic_list}  <<found metas>> #{metas.count}")
    # meta contains the pictures; tree_id contains the referenced tree; add to the hash {:tree => [id, id]}
    metas.each do |m|
      Rails.logger.info(">>>Add_Assigned_Pics: Meta: #{m.inspect}")
      # TODO weed out references to the same trees
      #
      #Rails.logger.info(">>>Add_Assigned_Pics_AFTER: Trees: #{trees}")
      m.assignedrefs.create(:ref => tree_id, :ref_type => "tree")
    end
    true    # TODO what to do if one fails
  end

  # Called with a particular model to indicate that associated pictures need to be removed
  # in all Pics that have the modelref
  def self.delete_event(modelref)
    metas = self.find_by_assigned_ref_with_id(modelref, options={:with_pictures => false})
    Rails.logger.info(">>>Remove Event: << model>> #{modelref.inspect}  <<found metas>> #{metas.count}")
    metas.each do |m|
      m.delete_assigned_pics(modelref.id.to_s)
    end
  end

  def self.search(keyword)
    metas = Picmeta.search(keyword)
    pictures = []
    metas.each do |m|
      pic = Picture.find_by_id(m.ext_picture_id)
      pictures << pic if pic
    end
    #Rails.logger.info(">>>Search in Picmeta: #{pictures.inspect}, #{metas.inspect}, #{metas.count}")
    normaliseall(pictures, metas)
  end


  # 
  # An instance is initialised with the results of a previous Class-level find (which already contains the results)
  # or if there are no options, then initialise the picture and meta variables with empty active record objects
  #
  def initialize(options={})
    options[:pic] != nil ? @picture = options[:pic] : @picture = Picture.new
    options[:meta] != nil ? @meta = options[:meta] : @meta = Picmeta.new
  end
  
  
  #
  # TODO: This only deals with updating the meta data, not the picture!!!
  #
  def update(params)
    if @meta.update_attributes(params[:pictureandmeta][:picmeta])
      true
    else
      false
    end
  end
  
  def destroy
    ok = false
    ok = true if @picture.destroy
    if ok
      ok = true if @meta.destroy
    end
    ok
  end
  
 # Delete trees from the assigned picture hash
  # Params: Tree_id; a Mongo UUID as a string
  # return: boolean result of the saved picmeta.
  def delete_assigned_pics(model_id)
    Rails.logger.info(">>>Delete Assigned Pics: #{self.inspect}")
    @meta.assignedrefs.where(:ref => model_id).delete_all
    #raise PicmetaError unless pm.meta.save
  end


  private
  
  def self.normaliseall(pics, metas)
    #
    # Return an array containing a collection of Pictureandmeta instances for only those pictures 
    # and metas that both have the same ids. 
    # THIS NEEDS TO BE REMOVE AS ITS ONLY ABOUT TESTING ERRORS 
    #
    newm = metas.select {|m| pics.collect {|p| p.id.to_s}.include? m.ext_picture_id}
    pmarray = []
    newm.each do |nm|
      pmarray << Pictureandmeta.new(pic: pics.select {|p| p.id == nm.ext_picture_id.to_i}[0], meta: nm)
    end
    pmarray
  end
  
  def self.tag_ify(tags)
    tags.split(/,/)
  end
end