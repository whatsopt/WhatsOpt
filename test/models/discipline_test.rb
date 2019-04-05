require 'test_helper'
require 'whats_opt/discipline'

class DisciplineTest < ActiveSupport::TestCase
  
  test "should be created with a name" do
    disc = Discipline.create(name: 'TEST')
    assert disc.valid?
    disc = Discipline.create()
    refute disc.valid?
  end
  
  test "should have a default kind" do
    disc = Discipline.create(name: 'TEST')
    assert_equal WhatsOpt::Discipline::DISCIPLINE, disc.type    
  end
  
  def test_as_json
    disc = disciplines(:geometry)
    adapter = ActiveModelSerializers::SerializableResource.new(disc)
    assert_equal [:analysis_id, :id, :name, :position, :type], adapter.as_json.keys.sort
  end

  test "should have default opendmao implementation" do
    disc = Discipline.new(name: 'NewDisc')
    assert disc.openmdao_impl
  end

end
