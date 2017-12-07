require 'whats_opt/jupyter_notebook_converter'

module Paperclip
  class NotebookProcessor < Processor

    def make
      @converter = WhatsOpt::JupyterNotebookConverter.new(@file, {:format => :html})
      @converter.convert
    end

  end
end
