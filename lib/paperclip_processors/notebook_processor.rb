require 'whats_opt/jupyter_notebook'

module Paperclip
  class NotebookProcessor < Processor

    def make
      @extractor = WhatsOpt::JupyterNotebook.new(@file, {:format => :html})
      @extractor.make
    end

  end
end
