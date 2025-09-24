class AddCompositeIndexToRecentFolloweeSleeps < ActiveRecord::Migration[8.0]
  def change
    add_index :recent_followee_sleeps, [ :follower_id, :duration ], order: { duration: :desc }
    add_index :recent_followee_sleeps, [ :follower_id, :start_time ]
  end
end
