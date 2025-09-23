class UpdateRecentFolloweeSleepsToVersion2 < ActiveRecord::Migration[8.0]
  def change
    update_view :recent_followee_sleeps,
      version: 2,
      revert_to_version: 1,
      materialized: { side_by_side: true }
  end
end
