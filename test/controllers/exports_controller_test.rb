require 'test_helper'

class ExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @mda = analyses(:cicav)
  end
  
  test "should get new openmdao zip archive given an mda_id" do
    get mda_exports_new_url(mda_id: @mda.id, format: :openmdao)
    assert_response :success
  end

  test "should get cmdows file given an mda_id" do
    get mda_exports_new_url(mda_id: @mda.id, format: :cmdows)
    assert_response :success
  end
    
end
