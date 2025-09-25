class AddSplitCompositePartialIndexToUserSleeps < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :user_sleeps, [ :user_id, :start_time ], where: "end_time IS NOT NULL", algorithm: :concurrently
    add_index :user_sleeps, [ :user_id, :duration ], order: { duration: :desc }, where: "end_time IS NOT NULL", algorithm: :concurrently
  end
end
