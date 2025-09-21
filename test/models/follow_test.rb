require "test_helper"

class FollowTest < ActiveSupport::TestCase
  setup do
    @follow = follows(:one)
  end

  test "should not follow same user twice" do
    new_follow = Follow.new(follower: @follow.follower, followed: @follow.followed)
    assert_not new_follow.save, "Followed the same user twice"
  end
end
