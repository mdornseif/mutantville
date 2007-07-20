include ActionView::Helpers::TextHelper

class Writing < ActiveRecord::Base  
  belongs_to :site
  #belongs_to :created_by,  :class_name => "User", :foreign_key => 'created_by_id'
  #belongs_to :modified_by, :class_name => "User", :foreign_key => 'modified_by_id'
  #belongs_to :updated_by, :class_name => "User", :foreign_key => 'modified_by_id'
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by"

  def title_or_text
    ret = read_attribute('TEXT_TITLE')
    if ret.empty?
      ret = ActionView::Helpers::TextHelper.truncate(self.content)
    end
    return ret
  end
end

class Story < Writing
  has_many :comments, :order => 'created_at DESC'
  #acts_as_taggable
  
  def before_save
    self.day = Time::now.strftime('%Y%m%d') if not self.day
  end
  
  def may_comment?
    read_attribute('hasdiscussions')
  end
  
  def show_comments?
    if read_attribute('hasdiscussions') or self.comments_count > 0 then return true end
    return false
  end
end

class Comment < Writing
  belongs_to :story
  belongs_to :comment
end
