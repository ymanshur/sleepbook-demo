class V1::User::FolloweeSleepsController < ApplicationController
  before_action :set_user
  before_action :set_user_followee_sleep, only: %i[ show ]

  # GET /users/1/followee_sleeps
  def index
    @pagy, @user_followee_sleeps = pagy(
      @user.recent_followee_sleeps.ranked,
      **pagination_params)

    render_pagy_response(
      data: ActiveModelSerializers::SerializableResource.new(
        @user_followee_sleeps.includes(:sleep, :user),
        each_serializer: V1::User::RecentFolloweeSleepSerializer
      ),
      message: "Followed sleeps fetched successfully",
      status: :ok,
      meta: pagy_metadata(@pagy)
    )
  end

  # GET /users/1/followee_sleeps/1
  def show
    render_success_response(data: @user_followee_sleep, message: "Followed user fetched successfully")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_followee_sleep
      @user_followee_sleep = @user.followees_sleeps.find(params.expect(:id))
    end

    def set_user
      @user = User.find(params.expect(:user_id))
    end
end
