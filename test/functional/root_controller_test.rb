require File.dirname(__FILE__) + '/../test_helper'
require 'root_controller'

# Re-raise errors caught by the controller.
class RootController; def rescue_action(e) raise e end; end

class RootControllerTest < Test::Unit::TestCase
  def setup
    @controller = RootController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
