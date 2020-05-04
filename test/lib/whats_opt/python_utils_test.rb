# frozen_string_literal: true

require "test_helper"

class PythonUtilsTest < ActiveSupport::TestCase
  setup do
  end

  test "should parse '[1,2,3]' as array of float" do
    assert_equal [1, 2, 3], WhatsOpt::PythonUtils.str_to_ary("[1,2,3]")
  end

  test "should parse 'np.ones((2,3))' as array of float" do
    assert_equal [1.0]*6, WhatsOpt::PythonUtils.str_to_ary("np.ones((2,3))")
  end

  test "should raise exception when str is invalid" do
    assert_raises WhatsOpt::PythonUtils::ArrayParseError do
      assert_equal [1.0]*6, WhatsOpt::PythonUtils.str_to_ary("[2,3")
    end
  end

end