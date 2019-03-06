class Api::V1::UsersController < ApplicationController
  # skip_before_action :authorized, only: [:create]
  def dashboard
    render json: { user: UserSerializer.new(current_user) }, status: :accepted
  end
  def index
    @users = User.all
    render json: @users
  end
  def create
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token(user_id: @user.id)
      render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
    else
      render json: { error: 'something went wrong!' }, status: :not_acceptable
    end
  end #end create method

  def user_medications
    @user_meds = User.find_by(id: user_med_params[:id]).medications
    render json: { medications: @user_meds }
    # render json: { UserSerializer.mew(@user_meds) }
  end
  private
  def user_params
    params.require(:user).permit(:name, :username, :password )
  end
  def user_med_params
    params.permit(:id)
  end
end #end UsersController
