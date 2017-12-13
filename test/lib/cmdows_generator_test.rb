require 'test_helper'
require 'whats_opt/cmdows_generator'

class OpenmdaoGeneratorTest < ActiveSupport::TestCase

  def setup
    @mda = multi_disciplinary_analyses(:cicav)
    @cmdowsgen = WhatsOpt::CmdowsGenerator.new(@mda)
  end
    
  test "should generate cmdows file" do
    Dir.mktmpdir do |dir|
      puts @cmdowsgen.generate
    end
  end
  
end