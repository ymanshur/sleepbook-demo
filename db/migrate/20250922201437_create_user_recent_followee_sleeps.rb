class CreateUserRecentFolloweeSleeps < ActiveRecord::Migration[8.0]
  def change
    create_view :user_recent_followee_sleeps, materialized: true

    add_index :user_recent_followee_sleeps, [ :follower_id, :sleep_id ], unique: true
  end
end
