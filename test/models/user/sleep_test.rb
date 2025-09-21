require "test_helper"

class User::SleepTest < ActiveSupport::TestCase
  test "should not save sleep without user" do
    user_sleep = User::Sleep.new

    assert_not user_sleep.save, "Saved the sleep without user"
  end

  test "should not save sleep without start_time" do
    user_sleep = User::Sleep.new

    assert_not user_sleep.save, "Saved the sleep without start_time"
  end

  test "should not save sleep with nil duration" do
    user = users(:one)

    user_sleep = User::Sleep.create!(user:, start_time: Time.current)

    assert_not_nil user_sleep.duration, "Saved the sleep with nil duration"
  end

  test "should not completed sleep without positive duration" do
    user_sleep = user_sleeps(:three_active)

    # Complete the sleep by set the end_time
    assert_not user_sleep.update(end_time: user_sleep.start_time), "Completed the sleep with zero duration"
    assert_not user_sleep.update(end_time: user_sleep.start_time - 1.hour), "Completed the sleep with negative duration"
  end

  test "should not completed sleep without correct duration" do
    user = users(:one)

    user_sleep = User::Sleep.create!(user:, start_time: Time.current)

    duration = 6.hours
    user_sleep.update!(end_time: user_sleep.start_time + duration)

    assert_equal duration, user_sleep.duration, "Completed the sleep without correct duration"
  end
end
