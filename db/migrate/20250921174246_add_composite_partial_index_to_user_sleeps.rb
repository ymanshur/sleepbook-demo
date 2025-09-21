class AddCompositePartialIndexToUserSleeps < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :user_sleeps, [ :user_id, :start_time, :duration ],
              include: [ :end_time ], where: "end_time IS NOT NULL",
              name: "index_part_user_sleeps_on_user_id_and_start_time_and_duration",
              algorithm: :concurrently
  end
end
