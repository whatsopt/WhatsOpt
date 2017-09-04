require 'test_helper'

class DisciplineTest < ActiveSupport::TestCase
  
  test "should be created with a name" do
    disc = Discipline.create({ name: 'TEST'})
    assert disc.valid?
  end

end
