require 'test_helper'

class FacebookUsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:facebook_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create facebook_user" do
    assert_difference('FacebookUser.count') do
      post :create, :facebook_user => { }
    end

    assert_redirected_to facebook_user_path(assigns(:facebook_user))
  end

  test "should show facebook_user" do
    get :show, :id => facebook_users(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => facebook_users(:one).id
    assert_response :success
  end

  test "should update facebook_user" do
    put :update, :id => facebook_users(:one).id, :facebook_user => { }
    assert_redirected_to facebook_user_path(assigns(:facebook_user))
  end

  test "should destroy facebook_user" do
    assert_difference('FacebookUser.count', -1) do
      delete :destroy, :id => facebook_users(:one).id
    end

    assert_redirected_to facebook_users_path
  end
end
