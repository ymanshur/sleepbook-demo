class V1::User::SleepsController < ApplicationController
  before_action :set_user
  before_action :set_user_sleep, only: %i[ show update destroy ]

  # GET /users/1/sleeps
  def index
    @user_sleeps = @user.sleeps.all

    render json: @user_sleeps
  end

  # GET /users/1/sleeps/1
  def show
    render json: @user_sleep
  end

  # POST /users/1/sleeps
  def create
    @user_sleep = @user.sleeps.create!(user_sleep_params)

    render json: @user_sleep, status: :created
  end

  # PATCH/PUT /user/sleeps/1
  def update
    @user_sleep.update!(user_sleep_params)

    render json: @user_sleep
  end

  # DELETE /user/sleeps/1
  def destroy
    @user_sleep.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_sleep
      @user_sleep = User::Sleep.find_by!(id: params.expect(:id), user_id: @user.id)
    end

    def set_user
      @user = User.find(params.expect(:user_id))
    end

    # Only allow a list of trusted parameters through.
    def user_sleep_params
      params.expect(user_sleep: [ :start_time, :end_time, :duration ])
    end
end
