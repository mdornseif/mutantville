class Site < ActiveRecord::Base
  set_table_name "AV_SITE" 
  set_primary_key "SITE_ID"
  has_many :stories, :foreign_key => 'TEXT_F_SITE', :order => 'TEXT_CREATETIME DESC'
  
  def self.count_publicsites
    Site.count('SITE_ISONLINE > 0 AND SITE_ISBLOCKED = 0')
  end
  
  def title
    read_attribute('SITE_TITLE')
  end

  def tagline
    read_attribute('SITE_TAGLINE')
  end

  def alias
    read_attribute('SITE_ALIAS')
  end
  
  def lastupdate
    read_attribute('SITE_LASTUPDATE')
  end
  
  def age
    ((Time::now - read_attribute('SITE_CREATETIME')) / 1.day).to_i
  end
end
