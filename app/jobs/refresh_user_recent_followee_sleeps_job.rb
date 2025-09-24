class RefreshUserRecentFolloweeSleepsJob < ApplicationJob
  queue_as :default

  def perform
    User::RecentFolloweeSleep.refresh
  end
end
