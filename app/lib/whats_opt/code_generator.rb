# frozen_string_literal: true

require "zip"
require "open3"
require "pathname"

module WhatsOpt
  class CodeGenerator
    PYTHON = APP_CONFIG["python_cmd"] || "python"

    attr_accessor :genfiles, :prefix

    def initialize(mda)
      @prefix = "code"
      @comment_delimiters = { begin: '"""', end: '"""' }
      @mda = mda
      @template_dir = File.join(File.dirname(__FILE__), "templates")
      @genfiles = []
      @server_module = "server"
      @server_host = "localhost"
      @server_port = 31400
      @generator = self
    end

    # options: with_run: true, with_server: false, with_runops: true, user_agent: nil, sqlite_filename: nil
    def generate(options = {})
      zip_filename = nil
      stringio = nil
      @genfiles = []
      Dir.mktmpdir("#{prefix}_#{@mda.basename}_") do |dir|
        # dir='/tmp/test'
        zip_rootpath = Pathname.new(dir)
        zip_filename = File.basename(dir) + ".zip"
        _generate_code(dir, options)
        stringio = Zip::OutputStream.write_buffer do |zio|
          @genfiles.each do |filename|
            entry = Pathname.new(filename).relative_path_from(zip_rootpath)
            zio.put_next_entry(entry)
            File.open(filename) do |f|
              zio.write f.read
            end
          end
        end
      end
      stringio.rewind
      return stringio.read, zip_filename
    end

    def render_partial(file)
      ERB.new(File.read(File.join(@template_dir, file))).result(binding)
    end

    def _generate(filename, template_filename, gendir)
      template = File.join(@template_dir, template_filename)
      Rails.logger.info "Creating #{filename} from #{File.basename(template)}"
      filepath = File.join(gendir, filename) if gendir
      result = _comment_header(filepath)
      result += _run_template(template)
      fh = File.open(filepath, "w:utf-8")
      fh.print result
      fh.close
      @genfiles << filepath if !@genfiles.include?(filepath)
      filepath
    end

    def _run_template(name)
      erb = ERB.new(File.open(name, "rb:utf-8").read, nil, "-")
      erb.result(binding)
    end

    def _comment_header(filepath)
      <<HEADER
# -*- coding: utf-8 -*-
#{@comment_delimiters[:begin]}
  #{File.basename(filepath)} generated by WhatsOpt #{WhatsOpt::Version::VERSION}
#{@comment_delimiters[:end]}
HEADER
    end
  end
end
