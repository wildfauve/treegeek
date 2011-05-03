module ImagesHelper
  def image_for(image, size = :medium)
    #im = image.public_filename(size)
    link_to image_tag(image.public_filename), image.public_filename
  end
end