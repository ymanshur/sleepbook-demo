class V1::User::RecentFolloweeSleepSerializer < ApplicationSerializer
  attributes :id, :user_name, :start_time, :end_time, :duration,

  def id
    object.sleep_id
  end

  def user_name
    object.user.name
  end
end
