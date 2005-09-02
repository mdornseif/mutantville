ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  map.connect "", :controller => 'root', :action => 'index'
  map.connect 'login/:action/:id', :controller => 'login'
  map.connect '/list', :controller => 'root', :action => 'list'
  map.connect ":id/stories/:storyid", :controller => 'site', :action => 'show_story'
  map.connect ":id", :controller => 'site', :action => 'show'
  map.connect ":id/:action", :controller => 'site'
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
