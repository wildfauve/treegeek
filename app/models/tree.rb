class Tree

	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::Search

  	validate :kind_exists
  	validates_presence_of :location_desc

	field :location_desc
	field :given_name
	field :coord_lat
	field :coord_long
	field :date_planted, :type => Date
	# add who planted...but will require user model
	field :source

	embeds_many :dimensions
	referenced_in :kind

	search_in :given_name, :location_desc, :source, :kind => :botanic_name

	# returns any attribute (method) from the Kind class associated with this Tree; 
	# Note: also can use the references association instead of this.
	#
	# Supply a field will return only that field.
	# NOTE--Removed because the referenced_in is moved to this model.
	#def get_tree_kind_field(field)
		#Kind.only(field).where(:tree_id => self.id).first.send(field)
	#	@kind ||= Kind.where(:tree_id => self.id)
	#	@kind.first.send(field)
	#end


	# helper to add the kind reference and the dimensions embedding (called from controller)
	# a nil kind means that it wont be updated.
  def add_external_refs(kind_ref, dim)
    #raise if kind_ref.nil?
    if kind_ref != nil
      kind = Kind.find(kind_ref)
      kind.tree = self
      kind.save
    end
    self.dimensions.create(:height => {:value => dim[:hvalue], :unit => dim[:hunit]},
    :width => {:value => dim[:wvalue], :unit => dim[:wunit]},
    :observation => dim[:obs]) unless dim[:hvalue].empty? && dim[:wvalue].empty?
  end

  #remove all the external model references from the tree (those not managed by the MongoID deep delete
  def remove_references(options)
  	# just got to remove the assigned_pics Tree hash
  	Pictureandmeta.delete_event(self)
  end

  private

  def kind_exists
  	errors.add(:kind, "Must be added") if kind.nil?
  	#Rails.logger.info(">>>Validate kinds_exit>>>: #{kind.inspect}, #{errors.inspect}")
  end

end