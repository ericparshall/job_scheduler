require 'test_helper'

class TimeOffRequestsControllerTest < ActionController::TestCase
  setup do
    @time_off_request = time_off_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:time_off_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create time_off_request" do
    assert_difference('TimeOffRequest.count') do
      post :create, time_off_request: { comment: @time_off_request.comment, day_off_requested: @time_off_request.day_off_requested, manager_id: @time_off_request.manager_id, user_id: @time_off_request.user_id }
    end

    assert_redirected_to time_off_request_path(assigns(:time_off_request))
  end

  test "should show time_off_request" do
    get :show, id: @time_off_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @time_off_request
    assert_response :success
  end

  test "should update time_off_request" do
    patch :update, id: @time_off_request, time_off_request: { comment: @time_off_request.comment, day_off_requested: @time_off_request.day_off_requested, manager_id: @time_off_request.manager_id, user_id: @time_off_request.user_id }
    assert_redirected_to time_off_request_path(assigns(:time_off_request))
  end

  test "should destroy time_off_request" do
    assert_difference('TimeOffRequest.count', -1) do
      delete :destroy, id: @time_off_request
    end

    assert_redirected_to time_off_requests_path
  end
end
