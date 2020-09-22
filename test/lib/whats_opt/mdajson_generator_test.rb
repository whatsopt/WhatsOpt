# frozen_string_literal: true

require "test_helper"

class MdajsonGeneratorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
    @jsongen = WhatsOpt::MdajsonGenerator.new(@mda)
  end

  test "should generate mda json" do
    content = @jsongen.generate
    expected = sample_file("cicav_mda.json").read
    assert_equal expected, content
  end
end