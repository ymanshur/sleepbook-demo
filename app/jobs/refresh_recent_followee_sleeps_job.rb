class RefreshRecentFolloweeSleepsJob < ApplicationJob
  queue_as :default

  def perform
    RecentFolloweeSleep.refresh
  end
end
