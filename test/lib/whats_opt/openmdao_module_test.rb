require 'test_helper'

class FakeNamespace < Struct.new(:name)
  include WhatsOpt::OpenmdaoModule
end

class FakeOpenmdaoModule < Struct.new(:name)
  include WhatsOpt::OpenmdaoModule

  def path
    [FakeNamespace.new("module1"), FakeNamespace.new("module2"), FakeNamespace.new("disc")]
  end
end

class FakeAnalysis < Struct.new(:name)
  include WhatsOpt::OpenmdaoModule

  def path
    [FakeNamespace.new("module1"), FakeNamespace.new("module2"), FakeNamespace.new("analysis")]
  end
end

class OpenmdaoMappingTest < ActiveSupport::TestCase
  
  test "should have a valid py classname even with space in name" do
    @module = FakeOpenmdaoModule.new('PRF CICAV')
    assert_equal 'PrfCicav', @module.py_classname
  end
  
  test "should have a valid py modulename" do
    @module = FakeOpenmdaoModule.new('PRF CICAV')
    assert_equal 'prf_cicav', @module.py_modulename
  end

  test "should have a camelname" do
    @module = FakeOpenmdaoModule.new('PRF CICAV')
    assert_equal 'PrfCicav', @module.camelname
  end
  
  test "should modify modulename regarding root_modulename for disc" do
    @module = FakeOpenmdaoModule.new('Disc')
    WhatsOpt::OpenmdaoModule.root_modulename = "module1"
    assert_equal "module2.disc", @module.py_full_modulename
    WhatsOpt::OpenmdaoModule.root_modulename = "module2"
    assert_equal "disc", @module.py_full_modulename    
  end

  test "should modify modulename regarding root_modulename for analysis" do
    @module = FakeAnalysis.new('Analysis')
    WhatsOpt::OpenmdaoModule.root_modulename = "module1"
    assert_equal "module2.analysis", @module.py_full_modulename
    WhatsOpt::OpenmdaoModule.root_modulename = "module2"
    assert_equal "analysis", @module.py_full_modulename
    WhatsOpt::OpenmdaoModule.root_modulename = "analysis"
    assert_equal "", @module.py_full_modulename    
  end


end
