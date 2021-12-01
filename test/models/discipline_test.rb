# frozen_string_literal: true

require "test_helper"
require "whats_opt/discipline"

class DisciplineTest < ActiveSupport::TestCase
  test "should be created with a name" do
    disc = Discipline.create(name: "TEST")
    assert disc.valid?
    disc = Discipline.create()
    assert_not disc.valid?
  end

  test "should have a default kind" do
    disc = Discipline.create(name: "TEST")
    assert_equal WhatsOpt::Discipline::DISCIPLINE, disc.type
  end

  test "should be invalid" do
    assert_not Discipline.new(name: "te/st/").valid?
    assert_not Discipline.new(name: "1test").valid?
    assert Discipline.new(name: "__DRIVER__").valid?
    assert Discipline.new(name: "test.valid").valid?
    assert Discipline.new(name: "test valid").valid?
  end

  def test_as_json
    disc = disciplines(:geometry)
    adapter = ActiveModelSerializers::SerializableResource.new(disc)
    assert_equal [:endpoint, :id, :name, :type], adapter.as_json.keys.sort
  end

  test "should have default opendmao implementation" do
    disc = Discipline.new(name: "NewDisc")
    assert disc.openmdao_impl
  end

  test "can have an endpoint" do
    disc = Discipline.new(name: "NewDisc")
    assert_difference("Endpoint.count") do
      disc.update!(endpoint_attributes: { host: "test", port: 30000 })
    end
  end

  test "should copy a metamodel" do
    disc = disciplines(:disc_cicav_metamodel)
    mda = analyses(:singleton)
    copy = disc.build_copy(mda)
    assert :metamodel, copy.type
    assert copy.is_pure_metamodel?
  end

  test "should create ancestor when creating analysis_discipline" do
    disc = disciplines(:outermda_vacant_discipline)
    innermda = analyses(:singleton)
    outermda = analyses(:outermda)
    assert_difference("AnalysisDiscipline.count") do
      disc.create_sub_analysis_discipline!(innermda)
    end
    innermda.reload
    outermda.reload
    disc.reload
    assert innermda.has_parent?
    assert outermda, innermda.ancestors
    assert innermda.name, disc.name
  end

  test "should check sub_analysis connection" do
    disc = disciplines(:outermda_innermda_discipline)
    var = disc.variables.where(name: "z").take
    assert disc.is_sub_analysis_connected_by?(var)
  end
end
