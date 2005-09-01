require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites

  def setup
    @site = Site.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Site,  @site
  end
end
