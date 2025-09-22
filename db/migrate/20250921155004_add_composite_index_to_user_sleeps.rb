class AddCompositeIndexToUserSleeps < ActiveRecord::Migration[8.0]
  def up
    add_index :user_sleeps, [ :user_id, :start_time, :duration ]
  end

  def down
    remove_index :user_sleeps, [ :user_id, :start_time, :duration ], if_exists: true
  end
end
