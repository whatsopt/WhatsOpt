require 'test_helper'
require 'whats_opt/jupyter_notebook'

class JupyterNotebookTest < ActiveSupport::TestCase
  test "should make an html file from a notebook" do
    jn = WhatsOpt::JupyterNotebook.new(sample_file("notebook_sample.ipynb"))
    dst = jn.make
    assert File.exist?(dst.path)
  end
  
  test "should generate apologize html when bad file format" do
    jn = WhatsOpt::JupyterNotebook.new(sample_file("fake_notebook.ipynb"))
    dst = jn.make
    content = File.new(dst).read
    expected = WhatsOpt::JupyterNotebook::SORRY_MESSAGE_HTML
    assert_equal expected, content 
  end
end
