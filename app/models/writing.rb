include ActionView::Helpers::TextHelper

class Writing < ActiveRecord::Base  
  set_table_name "AV_TEXT" 
  set_primary_key "TEXT_ID"
  set_inheritance_column "TEXT_PROTOTYPE"
  belongs_to :site, :foreign_key => "TEXT_F_SITE"
  belongs_to :created_by, :class_name => "User", :foreign_key => "TEXT_F_USER_CREATOR"
  belongs_to :modified_by, :class_name => "User", :foreign_key => "TEXT_F_USER_MODIFIER"

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

  def title_or_text
    ret = read_attribute('TEXT_TITLE')
    if ret.empty?
      ret = ActionView::Helpers::TextHelper.truncate(self.content)
    end
    return ret
  end
end

class Story < Writing
  has_many :comments, :foreign_key => 'TEXT_F_TEXT_STORY', :order => 'TEXT_CREATETIME DESC'
  acts_as_taggable
  
  def may_comment
    read_attribute('TEXT_HASDISCUSSIONS')
  end
  
  def show_comments?
    if read_attribute('TEXT_HASDISCUSSIONS') or self.comments_count > 0 then return true end
    return false
  end
end

class Comment < Writing
  belongs_to :story, :foreign_key => 'TEXT_F_TEXT_STORY'
end
