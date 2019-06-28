# frozen_string_literal: true

require "test_helper"
require "whats_opt/utils"

class UtilsTest < ActiveSupport::TestCase
  include WhatsOpt::Utils

  def test_shape_of
    assert_equal "1", shape_of("1")
    assert_equal "1", shape_of("3")
    assert_equal "1", shape_of("3.14")
    assert_equal "1", shape_of("abcd")

    assert_equal "(1,)", shape_of("[2]")
    assert_equal "(3,)", shape_of("[1, 2, 3]")
    assert_equal "(2,2)", shape_of("[[1., 2], [3, 4]]")
    assert_equal "(2,3,4)", shape_of("[[[ 1,  1,  1,  1],
                                        [ 1,  1,  1,  1],
                                        [ 1,  1,  1,  1]],
                                       [[ 1,  1,  1,  1],
                                        [ 1,  1,  1,  1],
                                        [ 1,  1,  1,  1]]]")
  end
end
