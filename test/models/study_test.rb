require 'test_helper'

class StudyTest < ActiveSupport::TestCase
  test "should not save a study without a project" do
    study = Study.new
    assert_not study.save
  end

  test "should be named 'Unnamed' when newly initialized" do
    study = Study.new
    assert_equal "Unnamed", study.name
  end
  
  test "should not have notebook when empty" do
    study = Study.new
    assert !study.has_notebook?
  end
  
end
