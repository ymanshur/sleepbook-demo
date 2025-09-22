class V1::User::FolloweeSleepSerializer < ApplicationSerializer
  attributes :id, :user_name, :start_time, :end_time, :duration,

  def id
    object.sleep_id
  end

  def user_name
    object.user.name
  end

  def start_time
    object.sleep.start_time
  end

  def end_time
    object.sleep.end_time
  end
end
