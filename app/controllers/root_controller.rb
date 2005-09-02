class RootController < ApplicationController
  layout "root"
  
  def index
    @sites = Site.find(:all, :conditions => ['SITE_ISONLINE > 0 AND SITE_ISBLOCKED = 0'], :limit => 23,
                       :order => 'SITE_LASTUPDATE DESC')
  end

  def list
    @sites = Site.find(:all, :conditions => ['SITE_ISONLINE > 0 AND SITE_ISBLOCKED = 0'],
                       :order => 'SITE_ID DESC')
  end
end
