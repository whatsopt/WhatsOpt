require 'test_helper'
require 'mkmf' # for find_executable
MakeMakefile::Logging.instance_variable_set(:@log, File.open(File::NULL, 'w'))

class ExportsControllerTest < ActionDispatch::IntegrationTest
  
  def thrift?
    found ||= find_executable("thrift")
  end

  setup do
    sign_in users(:user1)
    @mda = analyses(:cicav)
  end
  
  test "should get new openmdao zip archive given an mda_id" do
    skip "Apache Thrift not installed" unless thrift?
    get mda_exports_new_url(mda_id: @mda.id, format: :openmdao)
    assert_response :success
  end

  test "should get cmdows file given an mda_id" do
    get mda_exports_new_url(mda_id: @mda.id, format: :cmdows)
    assert_response :success
  end
    
end
