class RootController < ApplicationController
  def index
    @sites = Site.find(:all, :conditions => ['SITE_ISONLINE > 0 AND SITE_ISBLOCKED = 0'], :limit => 23,
                       :order => 'SITE_LASTUPDATE DESC')
  end
end
