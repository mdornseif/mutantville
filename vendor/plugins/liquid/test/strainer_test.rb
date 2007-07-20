#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/test_helper'

class StrainerTest < Test::Unit::TestCase
  include Liquid

  def test_strainer
    assert_equal false, Strainer.ok?('__test__')
    assert_equal false, Strainer.ok?('test')
    assert_equal false, Strainer.ok?('instance_eval')
    assert_equal false, Strainer.ok?('__send__')
    assert_equal true, Strainer.ok?('size') # from the standard lib
  end
  
end