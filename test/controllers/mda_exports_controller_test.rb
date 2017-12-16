require 'test_helper'

class MdaExportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @mda = multi_disciplinary_analyses(:cicav)
  end
  
  test "should get new openmdao zip archive given an mda_id" do
    get mda_mda_exports_new_url(mda_id: @mda.id, format: :openmdao)
    assert_response :success
  end

  test "should get display alert if specified mda not found" do
    get mda_mda_exports_new_url({:mda_id => '42'})
    assert_redirected_to(controller: 'multi_disciplinary_analyses', action: 'index')
    assert_equal 'MDA(id=42) not found!', flash[:alert]
  end

  test "should get cmdows file given an mda_id" do
    get mda_mda_exports_new_url(mda_id: @mda.id, format: :cmdows)
    assert_response :success
  end
    
end
