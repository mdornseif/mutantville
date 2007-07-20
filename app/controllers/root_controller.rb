class RootController < ApplicationController
  layout "root"
  
  def index
    @sites = Site.find(:all, :conditions => ['isonline > 0 AND isblocked = 0'], :limit => 23,
                       :order => 'lastupdate DESC')
  end

  def list
    @sites = Site.find(:all, :conditions => ['isonline > 0 AND isblocked = 0'],
                       :order => 'id DESC')
  end
end
