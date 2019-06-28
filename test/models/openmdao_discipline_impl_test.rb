# frozen_string_literal: true

require "test_helper"

class OpenmdaoDisciplineImplTest < ActiveSupport::TestCase
  setup do
    @geo = openmdao_discipline_impls(:openmdao_geometry_impl)
  end

  test "should have a default implementation" do
    odi = OpenmdaoDisciplineImpl.new
    assert_not odi.implicit_component.nil?
    assert_not odi.support_derivatives.nil?
  end

  test "should have a json representation" do
    assert @geo.as_json
  end
end
