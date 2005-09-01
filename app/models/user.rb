class User < ActiveRecord::Base
  set_table_name "AV_USER" 
  set_primary_key "USER_ID"

  def name
    read_attribute('USER_NAME')
  end
  
  def name=(name)
    write_attribute('USER_NAME', name)
  end

  def url
    read_attribute('USER_URL')
  end

  def url=(url)
    write_attribute('USER_URL', url)
  end
end
