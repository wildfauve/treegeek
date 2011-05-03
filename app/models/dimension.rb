class Dimension
	include Mongoid::Document
	include Mongoid::Timestamps

	embedded_in :tree, :inverse_of => :dimensions

	field :height, :type => Hash, :required => true
	field :width, :type => Hash
	field :observation

end