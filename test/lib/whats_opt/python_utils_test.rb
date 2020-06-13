# frozen_string_literal: true

require "test_helper"

class PythonUtilsTest < ActiveSupport::TestCase
  include WhatsOpt::PythonUtils

  setup do
  end

  test "should parse '[1,2,3]' as array of float" do
    assert_equal [1, 2, 3], str_to_ary("[1,2,3]")
  end

  test "should parse 'np.ones((2,3))' as array of float" do
    assert_equal [1.0]*6, str_to_ary("np.ones((2,3))")
  end

  test "should raise exception when str is invalid" do
    assert_raises ArrayParseError do
      assert_equal [1.0]*6, str_to_ary("[2,3")
    end
  end

  test "should escape dangerous python characters" do
    assert_equal "a__QUOTE__b", sanitize_pystring("a'b")
    assert_equal "a__HASHTAG__b", sanitize_pystring("a#b")
    assert_equal "a__DOUBLE_QUOTE__b", sanitize_pystring('a"b')
    assert_equal "a__BACKQUOTE__b", sanitize_pystring("a`b")
    assert_equal "a__EXCLAMATION__b", sanitize_pystring("a!b")
  end
end
