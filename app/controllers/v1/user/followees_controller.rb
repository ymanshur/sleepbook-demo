class V1::User::FolloweesController < ApplicationController
  wrap_parameters :user_followee

  before_action :set_user
  before_action :set_user_followee, only: %i[ show destroy ]

  # GET /users/1/followees
  def index
    @user_followees = @user.followees.all

    render json: @user_followees
  end

  # GET /users/1/followees/1
  def show
    render json: @user_followee
  end

  # POST /users/1/followees
  def create
    @followee = User.find(user_followee_params[:followed_id])
    @user.followees << @followee

    render json: @followee, status: :created
  end

  # DELETE /users/1/followees/1
  def destroy
    follow = Follow.find_by!(follower: @user, followed: @user_followee)
    follow.destroy!
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
