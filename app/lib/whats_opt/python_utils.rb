require "open3"
require "json"

module WhatsOpt
  module PythonUtils
    PYTHON = APP_CONFIG["python_cmd"] || "python"

    class ArrayParseError < StandardError
    end

    def str_to_ary(str)
      str = sanitize_pystring(str)
      out, err, status = Open3.capture3("#{PYTHON} << EOF\nimport numpy as np\nprint(np.array(#{str}).reshape((-1,)).tolist())\nEOF")
      raise ArrayParseError.new(err) unless status.exitstatus == 0
      JSON.parse(out.chomp)
    end

    def sanitize_pystring(str)
      str = str.gsub(/"/, "__DOUBLE_QUOTE__")
      str = str.gsub(/'/, "__QUOTE__")
      str = str.gsub(/`/, "__BACKQUOTE__")
      str = str.gsub(/#/, "__HASHTAG__")
      str = str.gsub(/!/, "__EXCLAMATION__")
      str
    end
  end
end
