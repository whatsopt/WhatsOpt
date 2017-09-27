require 'test_helper'

class OpenmdaoGenerationControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:user1)
    @mda = multi_disciplinary_analyses(:cicav)
  end
  
  test "should get new openmdao zip archive given an mda_id" do
    get mda_openmdao_generation_new_url(@mda)
    assert_response :success
  end

  test "should get display alert if specified mda not found" do
    get mda_openmdao_generation_new_url({:mda_id => '42'})
    assert_redirected_to(controller: 'multi_disciplinary_analyses', action: 'index')
    assert_equal 'MDA(id=42) not found!', flash[:alert]
  end
  
end
