class BaseImage < ActiveRecord::Base
  set_table_name "AV_IMAGE" 
  set_primary_key "IMAGE_ID"
  belongs_to :site, :foreign_key => "IMAGE_F_SITE"
  belongs_to :created_by, :class_name => "User", :foreign_key => "IMAGE_F_USER_CREATOR"
  belongs_to :modified_by, :class_name => "User", :foreign_key => "IMAGE_F_USER_MODIFIER"

  def method_missing(method_id, *arguments)
    prefix = self.class.table_name[3..-1]
    columnname = prefix + '_' + method_id.to_s.upcase
    if attributes.include? columnname then return attributes[columnname]
    elsif method_id == :created_on then return [prefix + '_CREATETIME']
    elsif method_id == :modified_on then return [prefix + '_MODIFYTIME']
    else
      super
    end
  end

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
