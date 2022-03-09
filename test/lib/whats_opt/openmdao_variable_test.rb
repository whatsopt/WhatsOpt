# frozen_string_literal: true

require "test_helper"

class FakeOpenmdaoVariable < Struct.new(:name, :type, :shape, :io_mode, :units, :desc)
  include WhatsOpt::OpenmdaoVariable
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  def test_should_have_a_description_escaped
    @var = FakeOpenmdaoVariable.new("VAR2tesT", :Float, 1, :in, "m", "description")
    assert_equal "description (m)", @var.escaped_desc
  end
  def test_should_have_a_description_with_unit
    @var = FakeOpenmdaoVariable.new("VAR2tesT", :Float, 1, :in, "m", "'description'")
    assert_equal "\\'description\\' (m)", @var.escaped_desc
  end

  def test_should_have_a_description_without_unit
    @var = FakeOpenmdaoVariable.new("VAR2tesT", :Float, 1, :in, "", "description")
    assert_equal "description", @var.extended_desc
  end

end
