class Blog
	include Mongoid::Document
	include Mongoid::Timestamps

	field :title, :type => String
	field :entry, :type => String


end