class Picture < ActiveRecord::Base
	
  validates_attachment_presence :image
  
  has_attached_file :image,
    :styles => {
      :thumb => "100x100>",
      :small => "150x150>",
      :medium => "300x300>" }
end