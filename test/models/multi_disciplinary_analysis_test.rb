require 'test_helper'

class MultiDisciplinaryAnalysisTest < ActiveSupport::TestCase
  extend ActionDispatch::TestProcess
  
  test "should create an mda from a mda template excel file" do
    attach = sample_file('excel_mda_simple_sample.xlsm')
    mda = MultiDisciplinaryAnalysis.create!(attachment_attributes: {data: attach})
    assert mda.valid?
  end
  
end
