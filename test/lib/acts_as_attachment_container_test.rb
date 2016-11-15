require 'test_helper'
require 'study'

class ActsAsAttachmentContainer::Test < ActiveSupport::TestCase
  test_a_study_should_contain_documents  do
    assert_equal study.attach(sample_file())
  end
end
