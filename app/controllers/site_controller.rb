class SiteController < ApplicationController
  layout "site", :except => [:atom, :rss]
  model :writing

  def index
   redirect_to :controller => 'root'
  end

  def show
    @site = Site.find_by_SITE_ALIAS(@params[:id])
    if @params[:day]
      @stories = Story.find(:all, :conditions => ['TEXT_F_SITE = ? AND TEXT_ISONLINE > 1 AND TEXT_DAY = ?',
                                                  @site.id, @params[:day]],
                            :order => 'TEXT_MODIFYTIME DESC')
      @stories += Story.find(:all, :conditions => ['TEXT_F_SITE = ? AND TEXT_ISONLINE > 1 AND TEXT_DAY < ?',
                                                   @site.id, @params[:day]],
                             :limit => [0, 23-@stories.length].max, :order => 'TEXT_MODIFYTIME DESC')
    else
      @stories = Story.find(:all, :conditions => ['TEXT_F_SITE = ? AND TEXT_ISONLINE > 1', @site.id], 
                            :limit => 23, :order => 'TEXT_MODIFYTIME DESC')
    end
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
    @site = Site.find_by_SITE_ALIAS(@params[:id])
    @story = Story.find(@params[:storyid])
    if @story.site != @site
      flash[:notice] = 'Story not found'
      redirect_to :action  => 'show'
    end
  end
  
  def list_image
    @site = Site.find_by_SITE_ALIAS(@params[:id])
    @images = Image.find(:all, :conditions => ['IMAGE_F_SITE = ? AND IMAGE_F_IMAGE_THUMB > 0', @site.id])
  end
  
  def show_image
    @site = Site.find_by_SITE_ALIAS(@params[:id])
    @image = Story.find(@params[:imageid])
    if @image.site != @site
      flash[:notice] = 'Image not found'
      redirect_to :action  => 'show'
    end
  end
  
  
  def edit
  end
end
