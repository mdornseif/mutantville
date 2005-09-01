class SiteController < ApplicationController
  layout "default"
  scaffold :site
  model :writing

  def show
    if @params[:id] != @params[:id].to_i.to_s
      @site = Site.find_by_SITE_ALIAS(@params[:id])
    else
      @site = Site.find(@params[:id])
    end
    @stories = @site.stories.slice(0,8)
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
