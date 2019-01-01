require 'test_helper'

class NotebookControllerTest < ActionDispatch::IntegrationTest

  setup do
    sign_in users(:user1)
    @nb = fixture_file_upload 'notebook_sample.ipynb'
    @nb2 = fixture_file_upload 'notebook_sample.ipynb'
  end

  test "should get notebooks list" do
    get notebooks_url
    assert_response :success  
  end
  
  test "should assign owner on creation" do
    assert_difference('Notebook.count') do
      post notebooks_url, params: { notebook: {title: "Test", attachment_attributes: { data: @nb }} }
    end
    assert_equal Notebook.last.owner, users(:user1)  
  end
  
  test "should not destroy notebook, if not owner" do
    post notebooks_url, params: { notebook: {title: "Test", attachment_attributes: { data: @nb }} }
    sign_out users(:user1)
    sign_in users(:user2)
    assert_difference('Notebook.count', 0) do
      delete notebook_url(Notebook.first)
    end
    assert_redirected_to root_path
    assert_equal 'You are not authorized to perform this action.', flash[:error]
  end  
  
  test "should update the attachment and the title" do
    post notebooks_url, params: { notebook: {title: "Test", attachment_attributes: { data: @nb }} }
    assert_equal "Test", Notebook.last.title
    put notebook_url(Notebook.last), params: { notebook: {title: "Test2", attachment_attributes: { data: @nb2 }} }
    assert_equal "Test2", Notebook.last.title
  end 
  
end
