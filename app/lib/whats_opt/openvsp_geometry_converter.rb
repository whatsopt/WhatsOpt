# frozen_string_literal: true

require "erubi"
require "tmpdir"
require "open3"

module WhatsOpt
  class OpenvspGeometryConverter
    SORRY_MESSAGE = "Oops, can not convert geometry!"
    SORRY_MESSAGE_HTML = "<p><strong>" + SORRY_MESSAGE + "</strong></p>"

    OPENVSP_SCRIPT = APP_CONFIG["openvsp_cmd"] || "vspscript"
    GEN_VSPSCRIPT = "convert_vsp3_to_x3d.script"

    class GeometryConversionError < StandardError
    end

    def initialize(file = "input.vsp3", options = { format: :x3d })
      @file    = file
      @options = options
      @orig_format = ".vsp3"
      @format = options[:format]
      @template = File.join(File.dirname(__FILE__), "templates", "convert_vsp3_to_x3d.script.erb")
      @input_filename = "input.vsp3"
      @output_filename = "output.x3d"
    end

    def convert
      return File.new(@file.path) if File.extname(@file.path) != @orig_format
      return File.new(@file.path) unless @options && @options[:format]

      @basename = File.basename(@file.path, @orig_format)
      src = @file
      filename = [@basename, @format ? ".#{@format}" : ""]
      dst = Tempfile.new(filename)
      ok = false
      Dir.mktmpdir do |dir|
        @input_filename = src.path
        @output_filename = dst.path
        self.generate_vspscript dir
        genscript = File.join(dir, GEN_VSPSCRIPT)

        cmd = "#{OPENVSP_SCRIPT} -script #{genscript}"
        Rails.logger.info "RUN COMMAND: #{cmd}"
        ok = self.run(cmd)
      end

      unless ok
        dst.write(SORRY_MESSAGE_HTML)
        dst.flush
      end
      dst
    end

    def run(cmd)
      ok = false
      Open3.popen2e(cmd) do |stdin, stdout_err, wait_thr|
        while line = stdout_err.gets
          Rails.logger.info line
        end
        exit_status = wait_thr.value
        ok = exit_status.success?
      end
      ok
    end

    def generate_vspscript(gendir)
      Rails.logger.info "Creating #{GEN_VSPSCRIPT} from #{File.basename(@template)}"
      filepath = File.join(gendir, GEN_VSPSCRIPT) if gendir
      result = _run_template(@template)
      fh = File.open(filepath, "w:utf-8")
      fh.print result
      fh.close
      filepath
    end

    def _run_template(name)
      erb = ERB.new(File.open(name, "rb:utf-8").read, nil, "-")
      erb.result(binding)
    end
  end
end
