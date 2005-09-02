# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Localization
  
  def link_if_possible(text, url=nil)
    return "<a href='#{h url}'>#{h text}</a>" if url
    return text
  end
  
  def server_url_for(options = {})
    if RAILS_ENV == 'development'
      @request.protocol + @request.host_with_port + url_for(options)
    else
      # use canonical url
      URLBASE + url_for(options)
    end
  end 
end
