# frozen_string_literal: true

require "test_helper"

class AttachmentTest < ActiveSupport::TestCase
  test "should not be valid if empty" do
    attach = Attachment.new
    assert_not attach.valid?
  end

end
