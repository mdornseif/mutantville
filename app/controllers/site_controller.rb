class SiteController < ApplicationController
  layout "site", :except => [:atom, :rss]
  model :writing
  before_filter :set_site
  before_filter :login_required, :only => [ :edit, :story_new, :story_new ]

  def index
   redirect_to :controller => 'root'
  end

  def show
    if @params[:day]
      @stories = Story.find(:all, :conditions => ['site_id = ? AND isonline > 0 AND day = ?',
                                                  @site.id, @params[:day]],
                            :order => 'created_at DESC')
      @stories += Story.find(:all, :conditions => ['site_id = ? AND isnonline > 0 AND day < ?',
                                                   @site.id, @params[:day]],
                             :limit => [0, MAXSTORIESONPAGE-@stories.length].max, :order => 'created_at DESC')
    else
      @stories = Story.find(:all, :conditions => ['site_id = ? AND isonline > 1', @site.id], 
                            :limit => MAXSTORIESONPAGE, :order => 'created_at DESC')
    end
    set_site_vars
  end

  def atom
    @headers["Content-Type"] = "application/xml"
    @stories = Story.find(:all, :conditions => ['TEXT_F_SITE = ? AND TEXT_ISONLINE > 0', @site.id], 
                          :limit => MAXSTORIESONPAGE, :order => 'TEXT_MODIFYTIME DESC')
  end

  def rss
    atom
  end
  
  def stylesheet
    @headers["Content-Type"] = "text/css" 
    render_text @site.layout.get_skin('Site','style').source
  end

  def update
    if @site.update_attributes(@params[:site])
      flash['notice'] = 'Preferences have been updated'
      redirect_to :action => 'show', :sitealias => @site.alias
    else
      render_action 'edit'
    end
  end

  def story_show
    @story = Story.find(@params[:storyid])
    if @story.site != @site
      flash[:notice] = 'Story not found'
      redirect_to :action  => 'show'
    end
    set_site_vars
  end

  def story_list
    @story_pages, @stories = paginate :story, 
                             :conditions => "site_id = %d" % @site.id, 
                             :order_by => "id DESC", :per_page => MAXSTORIESONPAGE

    set_site_vars
  end
  
  def story_new
    @story = Story.new
    set_site_vars
  end
  
  def story_create
    @story = Story.new(@params[:story])
    @story.site = @site
    if @story.save
      flash['notice'] = 'Story has been saved'
      redirect_to :action  => 'story_show', :sitealias => @site.alias, :storyid =>  @story.id
    else
      render_action 'story_new'
    end
  end

  def story_edit
    @story = Story.find(@params[:storyid])
    set_site_vars
  end

  def story_update
    @story = Story.find(@params[:storyid])
    if @story.update_attributes(@params[:story])
      flash['notice'] = 'Story has been updated'
      redirect_to :action => 'story_show', :sitealias => @site.alias, :storyid =>  @story.id
    else
      render_action 'story_edit'
    end
  end

  def list_image
    @images = Image.find(:all, :conditions => ['IMAGE_F_SITE = ? AND IMAGE_F_IMAGE_THUMB > 0', @site.id])
  end
  
  def show_image
    @image = Story.find(@params[:imageid])
    if @image.site != @site
      flash[:notice] = 'Image not found'
      redirect_to :action  => 'show'
    end
  end
  
  
  def edit
    set_site_vars
  end

  private
  def set_site
    @site = Site.find_by_alias(@params[:sitealias])
  end

  def set_site_vars
    @recent_changes = @site.recent_changes.map do |i|
      h = i.attributes.clone
      h['title'] = i.rawcontent[0..30] + '...' if h['title'].to_s == ''
      if i.class == Comment
        h['url'] = url_for :action => 'story_show', :storyid => i.story_id, :anchor => i.id.to_s
      else
        h['url'] = url_for :action => 'story_show', :storyid => i.id
      end
      h
    end
  end
end
