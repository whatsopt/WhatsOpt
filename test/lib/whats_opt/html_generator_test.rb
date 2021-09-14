# frozen_string_literal: true

require "test_helper"
require "whats_opt/csv_case_generator"

class HtmlGeneratorTest < ActiveSupport::TestCase
  def setup
    @mda = analyses(:cicav)
  end

  test "should generate html from given analysis" do
    gen = WhatsOpt::HtmlGenerator.new @mda
    content, filename = gen.generate 
    assert_equal '<!doctype html>', content[0..14]
    assert_equal "xdsm.html", filename
  end
end
