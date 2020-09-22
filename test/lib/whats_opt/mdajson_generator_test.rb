# frozen_string_literal: true

require "test_helper"
require "whats_opt/json_mda_generator"

class MdajsonGeneratorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
    @jsongen = WhatsOpt::JsonMdaGenerator.new(@mda)
  end

  test "should generate mda json" do
    content = @jsongen.generate
    expected = sample_file("cicav_mda.json").read
    assert_equal expected, content
  end
end