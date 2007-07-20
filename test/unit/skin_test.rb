require File.dirname(__FILE__) + '/../test_helper'

class SkinTest < Test::Unit::TestCase
  fixtures :skins

  def setup
    @skin = Skin.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Skin,  @skin
  end
end
