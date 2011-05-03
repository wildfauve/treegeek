module KindsHelper
  def imageref(kind_name)
    image_tag (kind_name + ".jpg")
  end

  def page_for
  	text_field_tag :page, @page
  end

end
