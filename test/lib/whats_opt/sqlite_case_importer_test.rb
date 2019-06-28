# frozen_string_literal: true

require "test_helper"
require "whats_opt/sqlite_case_importer"

class SqliteCaseImporterTest < ActiveSupport::TestCase
  def setup
    @filename = @doe = sample_file("sellar_doe.sqlite").path
    @optim = sample_file("sellar_optimization.sqlite").path
  end

  test "should detect valid sqlite db" do
    @cr = WhatsOpt::SqliteCaseImporter.new(@filename)
    assert @cr.is_valid_sqlite_db(@filename)
  end

  test "read driver cases from doe sqlite db" do
    @cr = WhatsOpt::SqliteCaseImporter.new(@doe)
    assert_equal "LHS", @cr.driver_name
    assert_equal 50, @cr.num_cases
  end

  test "read driver cases from optim sqlite db" do
    @cr = WhatsOpt::SqliteCaseImporter.new(@optim)
    assert_equal "SLSQP", @cr.driver_name
    assert_equal 6, @cr.num_cases
    expected_cases = {
      ["x", 0, 1] => [2.0, 5.773159728050814e-15, 0.0, 1.69272439048138e-14, 0.0, 2.7785054656531913e-14],
      ["z", 0, 2] => [5.0, 2.864929262586654, 2.1265604752694096, 1.9833925652884428, 1.9776480513124424, 1.9776388833247471],
      ["z", 1, 2] => [2.0, 0.8256953050343647, 0.0, 5.361249872104824e-13, 0.0, 0.0],
      ["y2", 0, 1] => [12.154521862167641, 6.472531934492873, 4.053120950531983, 3.7667851305759643, 3.7552961026043996, 3.755277766639172],
      ["y1", 0, 1] => [26.569095627564167, 7.739008597855901, 3.7116352648439506, 3.180489041920894, 3.160032594262093, 3.1599999994713555],
      ["g2", 0, 1] => [-11.845478137832359, -17.527468065507126, -19.946879049468016, -20.233214869424035, -20.2447038973956, -20.24472223336083],
      ["g1", 0, 1] => [-23.409095627564167, -4.579008597855901, -0.5516352648439504, -0.020489041920893847, -3.259426209289984e-05, 5.286446835839342e-10],
      ["obj", 0, 1] => [32.569100892077444, 8.566249211046738, 3.7290033498757014, 3.2036153338358186, 3.183426116962671, 3.183393951118685]
    }
    assert_equal expected_cases, @cr.cases
    assert_includes @cr.cases_attributes, varname: "x", coord_index: -1, values: [2.0, 5.773159728050814e-15, 0.0, 1.69272439048138e-14, 0.0, 2.7785054656531913e-14]
    assert_includes @cr.cases_attributes, varname: "z", coord_index: 1, values: [2.0, 0.8256953050343647, 0.0, 5.361249872104824e-13, 0.0, 0.0]
    assert_equal [1, 1, 1, 1, 1, 1], @cr.success
  end
end
