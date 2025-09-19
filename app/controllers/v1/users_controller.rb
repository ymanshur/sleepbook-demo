class V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @pagy, @users = pagy(User.all, **pagination_params)

    render_pagy_response(
      data: @users,
      message: "Users fetched successfully",
      status: :ok,
      meta: pagy_metadata(@pagy)
    )
  end

  # GET /users/1
  def show
    render_success_response(data: @user, message: "User fetched successfully")
  end

  # POST /users
  def create
    @user = User.create!(user_params)

    render_success_response(data: @user, message: "User created successfully", status: :created)
  end

  # PATCH/PUT /users/1
  def update
    @user.update!(user_params)

    render_success_response(data: @user, message: "User updated successfully")
  end

  # DELETE /users/1
  def destroy
    @user.destroy!

    render_success_response(message: "User deleted successfully")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :name ])
    end
end
