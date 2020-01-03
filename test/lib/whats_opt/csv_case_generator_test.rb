# frozen_string_literal: true

require "test_helper"
require "whats_opt/csv_case_generator"

class CsvCaseGeneratorTest < ActiveSupport::TestCase
  def setup
    @ope = operations(:doe)
  end

  CSV_DATA = "success;x1;z[0];z[1];obj\n1;1.0;8;5;4\n0;2.5;3;4;5\n1;5;6;3;6\n1;7.5;9;2;7\n1;9.8;10;1;8\n"

  test "should generate csv file from given operation cases" do
    @csvgen = WhatsOpt::CsvCaseGenerator.new
    content, filename = @csvgen.generate @ope.sorted_cases, @ope.success
    assert_equal CSV_DATA, content
    assert_equal "cases.csv", filename
  end

  test "should generate csv zipped file from given operation cases" do
    zippath = Tempfile.new("cases.zip")
    File.open(zippath, "w") do |f|
      @csvgen = WhatsOpt::CsvCaseGenerator.new(zip: true)
      content, _ = @csvgen.generate @ope.sorted_cases, @ope.success
      f.write content
    end

    Zip::File.open(zippath) do |zip|
      zip.each do |entry|
        assert_equal CSV_DATA, entry.get_input_stream.read
      end
    end
  end
end
