require "test_helper"

class User::SleepTest < ActiveSupport::TestCase
  test "should not save user sleep without start_time" do
    user_sleep = User::Sleep.new
    assert_not user_sleep.save, "Saved the user sleep without start_time"
  end

  test "should set user sleep duration" do
    user = users(:one)
    user_sleep = User::Sleep.new(user:, start_time: Time.current)
    user_sleep.save
    assert_not_nil user_sleep.duration, "Saved the user sleep with nil duration"
  end
end
