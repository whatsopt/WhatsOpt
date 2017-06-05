require 'test_helper'
require 'whats_opt/openmdao_generator'

class FakeVar < Struct.new(:name)
end

class FakeDiscipline < Struct.new(:name, :input_variables, :output_variables)
end

class FakeMda < Struct.new(:name, :disciplines)
end

class OpenmdaoGeneratorTest < ActiveSupport::TestCase

  def setup
    @mda = 
      FakeMda.new('Cicav', [
        FakeDiscipline.new('Geometry',
                           [FakeVar.new('x1'), FakeVar.new('y2'), FakeVar.new('z')],
                           [FakeVar.new('x2'), FakeVar.new('y1')]),
        FakeDiscipline.new('Aerodynamics',
                           [FakeVar.new('x3'), FakeVar.new('y1'), FakeVar.new('z')],
                           [FakeVar.new('y3'), FakeVar.new('y2')])
                           ])
    @ogen = WhatsOpt::OpenmdaoGenerator.new(@mda)
  end
    
  test "should generate openmdao component for a given discipline an mda" do
    disc = @mda.disciplines[0]
    filepath = @ogen.generate_discipline(disc)
    assert File.exists?(filepath)
  end
  
  test "should generate openmdao process for an mda" do
    filepath = @ogen.generate
    assert File.exists?(filepath)
  end
  
end