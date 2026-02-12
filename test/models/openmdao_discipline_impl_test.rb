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
    assert_not odi.jax_component.nil?
    assert_equal false, odi.jax_component
  end

  test "should have a json representation" do
    assert @geo.as_json
  end
end
