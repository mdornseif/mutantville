class Skin < ActiveRecord::Base
  set_table_name "AV_SKIN" 
  set_primary_key "SKIN_ID"
  # set_inheritance_column "TEXT_PROTOTYPE"
  belongs_to :layout, :foreign_key => "SKIN_F_LAYOUT"
  belongs_to :site, :foreign_key => "SKIN_F_SITE"
  belongs_to :created_by, :class_name => "User", :foreign_key => "SKIN_F_USER_CREATOR"
  belongs_to :modified_by, :class_name => "User", :foreign_key => "SKIN_F_USER_MODIFIER"

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
