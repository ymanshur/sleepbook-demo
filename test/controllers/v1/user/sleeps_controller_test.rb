require "test_helper"

class V1::User::SleepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_sleep = user_sleeps(:one)
  end

  test "should get index" do
    get v1_user_sleeps_url(@user), as: :json
    assert_response :success
  end

  test "should create user_sleep" do
    assert_difference("User::Sleep.count") do
      post v1_user_sleeps_url(@user), params: { user_sleep: { duration: @user_sleep.duration, end_time: @user_sleep.end_time, start_time: @user_sleep.start_time } }, as: :json
    end

    assert_response :created
  end

  test "should show user_sleep" do
    get v1_user_sleep_url(@user, @user_sleep), as: :json
    assert_response :success
  end

  test "should update user_sleep" do
    patch v1_user_sleep_url(@user, @user_sleep), params: { user_sleep: { duration: @user_sleep.duration, end_time: @user_sleep.end_time, start_time: @user_sleep.start_time } }, as: :json
    assert_response :success
  end

  test "should destroy user_sleep" do
    assert_difference("User::Sleep.count", -1) do
      delete v1_user_sleep_url(@user, @user_sleep), as: :json
    end

    assert_response :success
  end
end
