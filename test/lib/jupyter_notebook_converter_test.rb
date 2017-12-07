require 'test_helper'
require 'whats_opt/jupyter_notebook_converter'

class JupyterNotebookConverterTest < ActiveSupport::TestCase
  test "should make an html file from a notebook" do
    jn = WhatsOpt::JupyterNotebookConverter.new(sample_file("notebook_sample.ipynb"))
    dst = jn.convert
    assert File.exist?(dst.path)
  end
  
  test "should generate apologize html when bad file format" do
    jn = WhatsOpt::JupyterNotebookConverter.new(sample_file("fake_notebook.ipynb"))
    dst = jn.convert
    content = File.new(dst).read
    expected = WhatsOpt::JupyterNotebookConverter::SORRY_MESSAGE_HTML
    assert_equal expected, content 
  end
end
