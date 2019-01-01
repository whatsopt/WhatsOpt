require 'test_helper'

class GeometryModelControllerTest < ActionDispatch::IntegrationTest

  def vspscript?
    system("which vspscript > /dev/null 2>&1")
  end

  setup do
    sign_in users(:user1)
    @gm = fixture_file_upload 'launcher.vsp3'
    @gm2 = fixture_file_upload 'launcher.vsp3'
  end

  test "should get geometry models list" do
    get geometry_models_url
    assert_response :success  
  end
  
  test "should assign owner on creation" do
    skip unless vspscript?
    assert_difference('GeometryModel.count') do
      post geometry_models_url, params: { geometry_model: {title: "Test", attachment_attributes: { data: @gm }} }
    end
    assert_equal GeometryModel.last.owner, users(:user1)  
  end
  
  test "should not destroy geometry model, if not owner" do
    skip unless vspscript?
    post geometry_models_url, params: { geometry_model: {title: "Test", attachment_attributes: { data: @gm }} }
    sign_out users(:user1)
    sign_in users(:user2)
    assert_difference('GeometryModel.count', 0) do
      delete geometry_model_url(GeometryModel.first)
    end
    assert_redirected_to root_path
    assert_equal 'You are not authorized to perform this action.', flash[:error]
  end  
  
  test "should update the attachment and the title" do
    skip unless vspscript?
    post geometry_models_url, params: { geometry_model: {title: "Test", attachment_attributes: { data: @gm }} }
    assert_equal "Test", GeometryModel.last.title
    put geometry_model_url(GeometryModel.last), params: { geometry_model: {title: "Test2", attachment_attributes: { data: @gm2 }} }
    assert_equal "Test2", GeometryModel.last.title
  end 
  
end
