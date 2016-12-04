require 'test_helper'
require 'whats_opt/jupyter_notebook'

class JupyterNotebookTest < ActiveSupport::TestCase
  test "should make an html file from a notebook" do
    jn = WhatsOpt::JupyterNotebook.new(sample_file("notebook_sample.ipynb"))
    jn.make
  end
end
