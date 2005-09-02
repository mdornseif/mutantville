module SiteHelper
  def history(site)
    writings = Writing.find(:all, :conditions => ["TEXT_F_SITE = ?", site.id], :limit => 10, 
                            :order => 'TEXT_MODIFYTIME DESC')
    render_partial 'partials/history', :writings => writings
    # return debug writings
  end
  
  def render_story_content(story)
    story.rawcontent.to_s.gsub(/[\r\n][\n\r]/, "<br />\n")
  end

  def show_image(image)
    return "<img src='#{STATICPATH}/#{image.site.alias}/images/#{image.filename}.#{image.fileext}'" +
           " width='#{image.width}' height='#{image.height}'>"
  end

  def show_thumbnail(image)
    return "<a href='#{STATICPATH}/#{image.site.alias}/images/#{image.filename}.#{image.fileext}'>" +
           show_image(image.thumbnail) + '</a>'
  end
end
