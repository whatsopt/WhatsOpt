require 'test_helper'
require 'whats_opt/cmdows_generator'

class CmdowsGeneratorTest < ActiveSupport::TestCase

  def setup
    @mda = multi_disciplinary_analyses(:cicav)
    @cmdowsgen = WhatsOpt::CmdowsGenerator.new(@mda)
  end
    
  test "should generate cmdows xml" do
    @cmdowsgen.generate
  end
  
end