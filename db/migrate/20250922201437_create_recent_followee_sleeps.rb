class CreateRecentFolloweeSleeps < ActiveRecord::Migration[8.0]
  def change
    create_view :recent_followee_sleeps, materialized: true

    add_index :recent_followee_sleeps, [ :follower_id, :sleep_id ], unique: true
  end
end
