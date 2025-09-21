require "test_helper"

class V1::User::FolloweesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @follow = follows(:one)
    @user = @follow.follower
    @followee = @follow.followed

    @followed = users(:three)
  end

  test "should get index" do
    get v1_user_followees_url(@user), as: :json
    assert_response :success
  end

  test "should create user_followee" do
    assert_difference("Follow.count") do
      post v1_user_followees_url(@user), params: { followed_id: @followed.id }, as: :json
    end

    assert_response :created
  end

  test "should show user_followee" do
    get v1_user_followee_url(@user, @followee), as: :json
    assert_response :success
  end

  test "should destroy user_followee" do
    assert_difference("Follow.count", -1) do
      delete v1_user_followee_url(@user, @followee), as: :json
    end

    assert_response :success
  end
end
