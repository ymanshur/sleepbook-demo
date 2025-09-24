class User::RecentFolloweeSleep < ApplicationRecord
  self.primary_key = :id

  belongs_to :user

  scope :ranked, -> { order(duration: :desc, sleep_id: :asc) }

  def readonly?
    true
  end

  def self.refresh
    Scenic.database
      .refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end
