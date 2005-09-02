class SiteController < ApplicationController
  layout "site", :except => [:atom, :rss]
  model :writing

  def index
   redirect_to :controller => 'root'
  end

  def show
    @site = Site.find_by_SITE_ALIAS(@params[:id])
    @stories = Story.find(:all, :conditions => ['TEXT_F_SITE = ? AND TEXT_ISONLINE > 1', @site.id], 
                          :limit => 23, :order => 'TEXT_MODIFYTIME DESC')
  end

  def atom
    @site = Site.find_by_SITE_ALIAS(@params[:id])
    @stories = Story.find(:all, :conditions => ['TEXT_F_SITE = ? AND TEXT_ISONLINE > 0', @site.id], 
                          :limit => 23, :order => 'TEXT_MODIFYTIME DESC')
  end

  def rss
    atom
  end

  def show_story
    if @params[:id] != @params[:id].to_i.to_s
      @site = Site.find_by_SITE_ALIAS(@params[:id])
    else
      @site = Site.find(@params[:id])
    end
    @story = Story.find(@params[:storyid])
    if @story.site != @site
      flash[:notice] = 'Story not found'
      redirect_to :action  => 'show'
    end
  end
  
  def edit
  end
end
