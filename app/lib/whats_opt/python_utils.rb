require 'open3'
require 'json'

module WhatsOpt
  module PythonUtils

    PYTHON = APP_CONFIG["python_cmd"] || "python"

    class ArrayParseError < StandardError
    end

    def self.str_to_ary(str)
      out, err, status = Open3.capture3("#{PYTHON} << EOF\nimport numpy as np\nprint(np.array(#{str}).reshape((-1,)).tolist())\nEOF")
      raise ArrayParseError.new(err) unless status.exitstatus == 0
      return JSON.parse(out.chomp)
    end

  end
end
