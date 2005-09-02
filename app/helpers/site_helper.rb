module SiteHelper
  def history(site)
    writings = Writing.find(:all, :conditions => ["TEXT_F_SITE = ?", site.id], :limit => 10, 
                            :order => 'TEXT_MODIFYTIME DESC')
    render_partial 'partials/history', :writings => writings
    # return debug writings
  end
  
  def render_story_content(story)
    story.content.to_s.gsub(/[\r\n][\n\r]/, "<br />\n")
  end
end
