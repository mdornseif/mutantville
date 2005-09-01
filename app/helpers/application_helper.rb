# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_if_possible(text, url=nil)
    return "<a href='#{h url}'>#{h text}</a>" if url
    return text
  end
end
