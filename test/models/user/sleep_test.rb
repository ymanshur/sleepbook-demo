require "test_helper"

class User::SleepTest < ActiveSupport::TestCase
  test "should not save user sleep without start_time" do
    user_sleep = User::Sleep.new
    assert_not user_sleep.save, "Saved the user sleep without start_time"
  end
end
