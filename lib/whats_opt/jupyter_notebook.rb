module WhatsOpt
  
  class JupyterNotebook

    def initialize(file, options={:format => :html})
      @file    = file
      @options = options
      @orig_format = ".ipynb"
      @format = options[:format]
    end

    def make
      return @file if File.extname(@file.path) != @orig_format
      return @file unless @options && @options[:format]

      @basename = File.basename(@file.path, @orig_format)
      src = @file
      filename = [@basename, @format ? ".#{@format}" : ""]
      dst = Tempfile.new(filename)
      dst_path = File.dirname(dst.path)
      dst_filename = File.basename(dst.path)

      cmd = "jupyter nbconvert --output-dir=#{dst_path} --output=#{dst_filename} #{src.path}"
      ok = system(cmd)

      dst
    end
    
  end
end
