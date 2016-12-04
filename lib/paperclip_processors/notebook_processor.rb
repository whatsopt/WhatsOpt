require 'whats_opt/jupyter_notebook'

module Paperclip
  class NotebookProcessor < Processor

    def make
      puts "FILE=#{@file} OPTIONS = #{@options}"
      @extractor = WhatsOpt::JupyterNotebook.new(@file, {:format => :html})
      p "TOOT"
      dst = @extractor.make
      p dst
      dst
    end

  end
end
