class V1::User::SleepsController < ApplicationController
  before_action :set_user
  before_action :set_user_sleep, only: %i[ show update destroy ]

  # GET /users/1/sleeps
  def index
    @pagy, @user_sleeps = pagy(@user.sleeps.all, **pagination_params)

    render_pagy_response(
      data: @user_sleeps,
      message: "Users' sleeps fetched successfully",
      status: :ok,
      meta: pagy_metadata(@pagy)
    )
  end

  # GET /users/1/sleeps/1
  def show
    render_success_response(data: @user_sleep, message: "Users' sleep fetched successfully")
  end

  # POST /users/1/sleeps
  def create
    @user_sleep = @user.sleeps.create!(user_sleep_params)

    render_success_response(data: @user_sleep, message: "Users' sleep created successfully", status: :created)
  end

  # PATCH/PUT /user/sleeps/1
  def update
    @user_sleep.update!(user_sleep_params)

    render_success_response(data: @user_sleep, message: "Users' sleep updated successfully")
  end

  # DELETE /user/sleeps/1
  def destroy
    @user_sleep.destroy!

    render_success_response(message: "Users' sleep deleted successfully")
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
