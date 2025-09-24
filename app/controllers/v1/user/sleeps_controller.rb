class V1::User::SleepsController < ApplicationController
  wrap_parameters :user_sleep

  before_action :set_user
  before_action :set_user_sleep, only: %i[ show update destroy ]

  # GET /users/1/sleeps
  def index
    @pagy, @user_sleeps = pagy(@user.sleeps.ordered, **pagination_params)

    render_pagy_response(
      data: @user_sleeps,
      message: "User's sleeps fetched successfully",
      status: :ok,
      meta: pagy_metadata(@pagy)
    )
  end

  # GET /users/1/sleeps/1
  def show
    render_success_response(data: @user_sleep, message: "User's sleep fetched successfully")
  end

  # POST /users/1/sleeps
  def create
    @user.sleeps.create!(user_sleep_params)
    @user_sleeps = @user.sleeps.recent.ordered

    render_success_response(data: @user_sleeps.limit(ENV.fetch("DEFAULT_SCOPE_LIMIT", 25).to_i), message: "User's sleep created successfully", status: :created)
  end

  # PATCH/PUT /user/sleeps/1
  def update
    @user_sleep.update!(user_sleep_params)

    render_success_response(data: @user_sleep, message: "User's sleep updated successfully")
  end

  # DELETE /user/sleeps/1
  def destroy
    @user_sleep.destroy!

    render_success_response(message: "User's sleep deleted successfully")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_sleep
      @user_sleep = @user.sleeps.find(params.expect(:id))
    end

    def set_user
      @user = User.find(params.expect(:user_id))
    end

    # Only allow a list of trusted parameters through.
    def user_sleep_params
      params.require(:user_sleep).permit(:start_time, :end_time)
    end
end
