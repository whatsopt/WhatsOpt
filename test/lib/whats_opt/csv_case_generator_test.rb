# frozen_string_literal: true

require "test_helper"
require "whats_opt/csv_case_generator"

class CsvCaseGeneratorTest < ActiveSupport::TestCase
  def setup
    @ope = operations(:doe)
  end

  test "should generate csv file from given operation cases" do
    @csvgen = WhatsOpt::CsvCaseGenerator.new
    content, filename = @csvgen.generate @ope.cases, @ope.success
    assert_equal "success;x1;obj\n1;1;4\n0;2;5\n1;3;6\n", content
    assert_equal "cases.csv", filename
  end

  test "should generate csv zipped file from given operation cases" do
    zippath = Tempfile.new("cases.zip")
    File.open(zippath, "w") do |f|
      @csvgen = WhatsOpt::CsvCaseGenerator.new(zip: true)
      content, _ = @csvgen.generate @ope.cases, @ope.success
      f.write content
    end

    Zip::File.open(zippath) do |zip|
      zip.each do |entry|
        assert_equal "success;x1;obj\n1;1;4\n0;2;5\n1;3;6\n", entry.get_input_stream.read
      end
    end
  end
end
