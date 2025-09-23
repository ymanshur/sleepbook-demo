class DummyDataGenerator
  def initialize
    @tnow = Time.current
    @origin_log_level = ActiveRecord::Base.logger.level

    # Define the number of records to create, with defaults
    @num_users = ENV.fetch("USERS", 1_000).to_i
    @num_sleeps_per_user = ENV.fetch("SLEEPS", 800).to_i
    @num_follows_per_user = ENV.fetch("FOLLOWS", 1_000).to_i
    @batch_size = 1_000
  end

  # Temporarily disable logging to prevent excessive log output
  def change_log_level(level: :fatal)
    ActiveRecord::Base.logger.level = level
  end

  def restore_log_level
    ActiveRecord::Base.logger.level = @origin_log_level
  end

  def check_env
    if Rails.env.production?
      puts "WARNING: This task is not intended for production. Aborting."
      exit 1
    end
  end

  def run_users_sleeps_task
    puts "Starting data generation process..."

    puts "Generating #{@num_users} users..."

    # Generate and insert users data in batches
    users_to_insert = []

    @num_users.times do
      created_at = @tnow - (rand(1..2).month + rand(0..28).days + rand(0..59).minutes + rand(0..59).second)

      users_to_insert << {
        name: Faker::Name.name,
        created_at: created_at,
        updated_at: created_at
      }

      if users_to_insert.length >= @batch_size
        created_users = User.insert_all(users_to_insert, returning: [ :id, :created_at ])
        puts "  ...inserted #{users_to_insert.length} users"

        populate_user_sleeps(created_users) unless created_users.empty?

        users_to_insert = []
      end
    end

    unless users_to_insert.empty?
      created_users = User.insert_all(users_to_insert, returning: [ :id, :created_at ])
      puts "  ...inserted #{users_to_insert.length} users"

      populate_user_sleeps(created_users) unless created_users.empty?
    end

    puts "Users and user's sleeps generated successfully."
  end

  def populate_user_sleeps(users)
    # Generate and insert user_sleeps data in batches
    sleeps_to_insert = []

    users.each do |user|
      current_time = @tnow

      @num_sleeps_per_user.times do
        break unless current_time >= user["created_at"]

        sleep_end_time = current_time
        sleep_start_time = sleep_end_time - (rand(2..8).hours + rand(0..59).minutes + rand(0..59).seconds)
        duration_in_seconds = (sleep_end_time - sleep_start_time).to_i

        sleep_to_insert = {
          user_id: user["id"],
          start_time: sleep_start_time,
          end_time: sleep_end_time,
          duration: duration_in_seconds,
          created_at: sleep_start_time,
          updated_at: sleep_end_time
        }

        # let one uncompleted sleep
        unless sleep_to_insert[:end_time] <= @tnow
          sleep_to_insert[:end_time] = nil
          sleep_to_insert[:duration] = nil
        end

        sleeps_to_insert << sleep_to_insert

        current_time = sleep_start_time - (rand(4..16).hours + rand(0..59).minutes + rand(0..59).seconds)

        if sleeps_to_insert.length >= @batch_size
          User::Sleep.insert_all(sleeps_to_insert, returning: false)
          puts "  ...inserted #{sleeps_to_insert.length} user_sleeps"

          sleeps_to_insert = []
        end
      end
    end

    unless sleeps_to_insert.empty?
      User::Sleep.insert_all(sleeps_to_insert, returning: false)
      puts "  ...inserted #{sleeps_to_insert.length} user_sleeps"
    end
  end

  def run_follows_task
    # Fetch all user for follosing relationships
    users = User.select(:id, :created_at).all

    puts "Generating follows data..."

    # Generate and insert follows data in batches
    follows_to_insert = []

    users.each do |user|
      followees = users.sample(@num_follows_per_user)
      followees.each do |followee|
        next unless user["id"] != followee["id"]
        next unless user["created_at"] <= followee["created_at"]

        created_at = followee["created_at"]
        follows_to_insert << {
          follower_id: user["id"],
          followed_id: followee["id"],
          created_at: created_at + rand(0..7).days,
          updated_at: created_at + rand(0..7).days
        }
      end

      if follows_to_insert.size >= @batch_size
        Follow.insert_all(follows_to_insert, returning: false)
        puts "  ...inserted #{follows_to_insert.size} follows"
        follows_to_insert = []
      end
    end

    Follow.insert_all(follows_to_insert, returning: false) unless follows_to_insert.empty?

    puts "User follows generated successfully."
  end

  def run_cleanup_task
    puts "Starting data cleanup..."

    # Use `delete_all` for a fast, no-callback deletion
    Follow.delete_all
    puts "  ...deleted all follows records"
    User::Sleep.delete_all
    puts "  ...deleted all user sleeps records"
    User.delete_all
    puts "  ...deleted all users records"
    RecentFolloweeSleep.delete_all
    puts "  ...deleted all recent followee sleeps records"

    # Reset primary key sequences for PostgreSQL to start from 1 again
    ActiveRecord::Base.connection.reset_pk_sequence!("users")
    ActiveRecord::Base.connection.reset_pk_sequence!("user_sleeps")
    ActiveRecord::Base.connection.reset_pk_sequence!("follows")

    puts "All records deleted."
  end
end

namespace :dummy do
  namespace :users_sleeps do
    desc "Generate a large amount of dummy users and their sleeps data"
    task load: :environment do
      g = DummyDataGenerator.new
      g.check_env
      g.change_log_level

      begin
        g.run_users_sleeps_task
      rescue => e
        puts "An error occurred: #{e.message}"
        puts e.backtrace
      ensure
        g.restore_log_level
        puts "Data generation completed!"
      end
    end
  end

  namespace :follows do
    desc "Generate a large amount of dummy followings data"
    task load: :environment do
      g = DummyDataGenerator.new
      g.check_env
      g.change_log_level

      begin
        g.run_follows_task
      rescue => e
        puts "An error occurred: #{e.message}"
        puts e.backtrace
      ensure
        g.restore_log_level
        puts "Data generation completed!"
      end
    end
  end

  desc "Clean up all dummy data"
  task cleanup: :environment do
    g = DummyDataGenerator.new
    g.check_env
    g.change_log_level

    begin
      g.run_cleanup_task
    rescue => e
      puts "An error occurred during cleanup: #{e.message}"
      puts e.backtrace
    ensure
      g.restore_log_level
      puts "Data cleanup completed!"
    end
  end
end
