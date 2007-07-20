class Layout < ActiveRecord::Base
  set_table_name  'AV_LAYOUT' 
  set_primary_key 'LAYOUT_ID'
  has_many   :skins, :foreign_key => 'SKIN_F_LAYOUT'
  belongs_to :parent, :class_name => 'Layout', :foreign_key => 'LAYOUT_F_LAYOUT_PARENT'
  belongs_to :site, :foreign_key => 'LAYOUT_F_SITE'
  belongs_to :created_by, :class_name => "User", :foreign_key => "LAYOUT_F_USER_CREATOR"
  belongs_to :modified_by, :class_name => "User", :foreign_key => "LAYOUT_F_USER_MODIFIER"

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

  def get_skin(klass, name)
    # follow the layout chain to get the skin
    ret = Skin.find(:first, :conditions => ['SKIN_F_LAYOUT = ? AND SKIN_PROTOTYPE = ? AND SKIN_NAME = ?',
                    self.id, klass, name])
    logger.error("could not get_skin(#{klass},#{name}) for layout_id=#{self.id}") if not (ret and self.parent)
    return self.parent.get_skin(klass, name) if not ret
    return ret
  end
end
