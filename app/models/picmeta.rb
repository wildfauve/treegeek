class Picmeta
  
  # when refactoring for Mongoid, consider validates_unqiueness_of helper
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  
  field :ext_picture_id, :type => String, :required => true
  field :name, :type => String, :required => true
  field :description, :type => String
  field :date_taken, :type => Time
  field :photographer, :type => String
  field :tags, :type => Array, :default => []
  field :random, :type => Float

  paginates_per 20

  embeds_many :assignedrefs

  search_in :name, :description
  
  # Overrides the default writer/reader for tags to turn the string into an array
  # TODO: consider other non-word separaters for tags
  def tags=(value)
    Rails.logger.info(">>>TAGS===: #{value}")
    write_attribute(:tags, value.split(/\W+/))
  end
  
  # Overrides the tags getter.
  # Joins into string separated by comma
  def tags
    t = read_attribute(:tags)
    t.nil? ? "" : t.join(', ')
  end
  
end