require 'test_helper'

class OpenmdaoGenerationControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @mda = multi_disciplinary_analyses(:cicav)
  end
  
  test "should get new openmdao zip archive given an mda_id" do
    get openmdao_generation_new_url(:mda_id => @mda.id)
    assert_response :success
  end

  test "should get display alert if mda not specified" do
    get openmdao_generation_new_url
    assert_redirected_to(controller: 'multi_disciplinary_analyses', action: 'index')
    assert_equal 'MDA not specified. Openmdao generation aborted!', flash[:alert]
  end

  test "should get display alert if specified mda not found" do
    get openmdao_generation_new_url(:mda_id => 42)
    assert_redirected_to(controller: 'multi_disciplinary_analyses', action: 'index')
    assert_equal 'MDA(id=42) not found!', flash[:alert]
  end
  
end
