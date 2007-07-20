class Site < ActiveRecord::Base
  has_many :stories, :order => 'created_at DESC'
  belongs_to :created_by,  :class_name => "User", :foreign_key => 'created_by_id'
  belongs_to :modified_by, :class_name => "User", :foreign_key => 'modified_by_id'
  # belongs_to :layout, :foreign_key => 'SITE_F_LAYOUT'

  def self.count_publicsites
    Site.count('isonline > 0 AND isblocked = 0')
  end
  
  def age
    ((Time::now - read_attribute('created_at')) / 1.day).to_i
  end

  def recent_changes
    Writing.find(:all, :conditions => ['site_id = ? AND isonline > 0', self.id], 
                       :limit => 10, :order => 'updated_at DESC')
  end
end
