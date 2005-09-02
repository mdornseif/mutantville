class BaseImage < ActiveRecord::Base
  set_table_name "AV_IMAGE" 
  set_primary_key "IMAGE_ID"
  belongs_to :site, :foreign_key => "IMAGE_F_SITE"
  belongs_to :user, :foreign_key => "IMAGE_F_USER_CREATOR"

  def alias 
    read_attribute('IMAGE_ALIAS') end
  def alttext
    read_attribute('IMAGE_ALTTEXT') end
  def fileext
    read_attribute('IMAGE_FILEEXT') end
  def filename
    read_attribute('IMAGE_FILENAME') end
  def width
    read_attribute('IMAGE_WIDTH') end
  def height
    read_attribute('IMAGE_HEIGTH') end
  def filesize
    read_attribute('IMAGE_FILESIZE') end
  def createtime
    read_attribute('IMAGE_CREATETIME') end
  def creator
    read_attribute('IMAGE_F_USER_CREATOR') end
end

class Layoutimage < BaseImage
end

class Image < BaseImage
  belongs_to :thumbnail, :class_name => "Thumbnail", :foreign_key => "IMAGE_F_IMAGE_THUMB"
end

class Thumbnail < Image
  belongs_to :parent, :class_name => "Thumbnail", :foreign_key => "IMAGE_F_IMAGE_THUMB"
end
