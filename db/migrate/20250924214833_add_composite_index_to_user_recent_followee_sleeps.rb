class AddCompositeIndexToUserRecentFolloweeSleeps < ActiveRecord::Migration[8.0]
  def change
    add_index :user_recent_followee_sleeps, [ :follower_id, :duration ], order: { duration: :desc }
    add_index :user_recent_followee_sleeps, [ :follower_id, :start_time ]
  end
end
