class V1::User::FolloweesController < ApplicationController
  wrap_parameters :user_followee

  before_action :set_user
  before_action :set_user_followee, only: %i[ show destroy ]

  # GET /users/1/followees
  def index
    @pagy, @user_followees = pagy(@user.followees.all, **pagination_params)

    render_pagy_response(
      data: @user_followees,
      message: "Followed users fetched successfully",
      status: :ok,
      meta: pagy_metadata(@pagy)
    )
  end

  # GET /users/1/followees/1
  def show
    render_success_response(data: @user_followee, message: "Followed user fetched successfully")
  end

  # POST /users/1/followees
  def create
    @followee = User.find(user_followee_params[:followed_id])
    @user.followees << @followee

    render_success_response(data: @followee, message: "User followed successfully", status: :created)
  end

  # DELETE /users/1/followees/1
  def destroy
    follow = Follow.find_by!(follower: @user, followed: @user_followee)
    follow.destroy!

    render_success_response(message: "User un-following successfully")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_followee
      @user_followee = @user.followees.find(params.expect(:id))
    end

    def set_user
      @user = User.find(params.expect(:user_id))
    end

    def user_followee_params
      params.expect(user_followee: [ :followed_id ])
    end
end
