require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase

  test "should not be valid if empty" do
    attach = Attachment.new
    assert !attach.valid?
  end
  
  test "should not be valid if bad extension" do
    attach = Attachment.new(data: sample_file("notebook_bad_ext.json"))
    assert !attach.valid?
  end

  test "should process notebook as html file" do
    attach = Attachment.new
    attach.update_attributes(data: sample_file("notebook_sample.ipynb"))
    path = attach.data.path(:original)
    assert File.exist?(path)
    path = attach.data.path(:html)
    assert File.exist?(path)    
  end
  
  test "should have category when valid" do
    attach = Attachment.new(data: sample_file("notebook_sample.ipynb"))
    assert attach.valid?
    assert_equal Attachment::ATTACH_NOTEBOOK, attach.category
  end
  
  test "should generate fake html if bad notebook html conversion" do
    attach = Attachment.new
    attach.update_attributes(data: sample_file("fake_notebook.ipynb"))
    expected = "<p><strong>Oops, can not convert notebook to html!</strong></p>"
    path = attach.data.path(:html)
    assert File.exist?(path)
    assert_equal expected, File.new(path).read
  end
   
end
