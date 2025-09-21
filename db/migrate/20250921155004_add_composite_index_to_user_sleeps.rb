class AddCompositeIndexToUserSleeps < ActiveRecord::Migration[8.0]
  def change
    add_index :user_sleeps, [ :user_id, :start_time, :duration ]
  end
end
