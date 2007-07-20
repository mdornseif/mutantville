# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.

require 'localization'
require 'login_system'

class ApplicationController < ActionController::Base
  include Localization
  include LoginSystem

  helper :Login
  model  :Login

  before_filter do |c|
    User.current_user = User.find(c.session['login'].id) unless c.session['login'].nil?
  end
    
  private
end