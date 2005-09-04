class Site < ActiveRecord::Base
  set_table_name "AV_SITE" 
  set_primary_key "SITE_ID"
  has_many :stories, :foreign_key => 'TEXT_F_SITE', :order => 'TEXT_CREATETIME DESC'
  belongs_to :created_by, :class_name => "User",:foreign_key => "SITE_F_USER_CREATOR"
  belongs_to :modified_by, :class_name => "User", :foreign_key => "SITE_F_USER_MODIFIER"
  belongs_to :layout, :foreign_key => 'SITE_F_LAYOUT'

  def get_from_preferences(name)
    # crude but works
    preferences = read_attribute('SITE_PREFERENCES')
    # multiline search!
    m = preferences.match /^    <#{name}>(.*)</#{name}>$/m
    print name, m[1], preferences
    return m[1] if m
  end
  
  def method_missing(method_id, *arguments)
    prefix = self.class.table_name[3..-1]
    columnname = prefix + '_' + method_id.to_s.upcase
    if attributes.include? columnname then return attributes[columnname]
    elsif method_id == :created_at then return [prefix + '_CREATETIME']
    elsif method_id == :modidied_at then return [prefix + '_MODIFYTIME']
    else
      print "else #{method_id.to_s}\n"
      ret = nil
      ret = get_from_preferences(method_id.to_s) if method_id.to_s != 'get_from_preferences'
      print "#{ret}\n"
      if ret.nil?
        super
      else
        return ret
      end
    end
  end
    
  def self.count_publicsites
    Site.count('SITE_ISONLINE > 0 AND SITE_ISBLOCKED = 0')
  end
  
  def age
    ((Time::now - read_attribute('SITE_CREATETIME')) / 1.day).to_i
  end
  
  def stylesheet
    
  end
end
