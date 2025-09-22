class RemoveCompositeIndexFromUserSleeps < ActiveRecord::Migration[8.0]
  def up
    remove_index :user_sleeps, name: :index_user_sleeps_on_user_id_and_start_time_and_duration
  end
end
