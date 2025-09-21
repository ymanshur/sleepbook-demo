require "test_helper"

class V1::User::FolloweeSleepsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follow = follows(:one)
    @user = @follow.follower
    @followee = @follow.followed

    @followee_sleep = @followee.sleeps.take
  end

  test "should get index" do
    get v1_user_followee_sleeps_url(@user), as: :json
    assert_response :success
  end

  test "should show user_followee_sleep" do
    get v1_user_followee_sleep_url(@user, @followee_sleep), as: :json
    assert_response :success
  end
end
