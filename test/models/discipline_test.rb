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

  test "should copy and predict with metamodel" do
    disc = disciplines(:disc_cicav_metamodel)
    mda = analyses(:singleton)
    copy = disc.create_copy!(mda)
    assert :metamodel, copy.type
    assert copy.is_pure_metamodel?
  end
end
