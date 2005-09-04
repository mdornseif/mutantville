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
    elsif method_id == :created_at then return [prefix + '_CREATETIME']
    elsif method_id == :modidied_at then return [prefix + '_MODIFYTIME']
    else
      super
    end
  end
end

class Layoutimage < BaseImage
end

class Image < BaseImage
  belongs_to :thumbnail, :class_name => "Thumbnail", :foreign_key => "IMAGE_F_IMAGE_THUMB"
end

class Thumbnail < Image
  belongs_to :parent, :class_name => "Thumbnail", :foreign_key => "IMAGE_F_IMAGE_THUMB"
end
