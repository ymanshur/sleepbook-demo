class V1::User::FolloweeSleepSerializer < ApplicationSerializer
  attributes :id, :user_name, :start_time, :end_time, :duration,

  def user_name
    object.user.name
  end
end
