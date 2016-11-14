require 'test_helper'

class StudyTest < ActiveSupport::TestCase
  test "should not save a study without a project" do
    study = Study.new
    assert_not study.save
  end
end
