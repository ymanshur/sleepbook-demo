class CreateUserSleeps < ActiveRecord::Migration[8.0]
  def change
    create_table :user_sleeps do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :duration

      t.timestamps
    end
  end
end
