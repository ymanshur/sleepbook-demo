class RecentFolloweeSleep < ApplicationRecord
  self.primary_key = "id"

  belongs_to :sleep, class_name: "User::Sleep", foreign_key: :sleep_id
  belongs_to :user

  scope :ordered, -> { order(duration: :desc) }

  def readonly?
    true
  end

  def self.refresh
    Scenic.database
      .refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end
