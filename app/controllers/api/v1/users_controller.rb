class Api::V1::UsersController < ApplicationController

  def index
    @users = User.all
    render json: @users
  end

  def create
    #code
  end

  def user_params
    params.require(:user).permit(:name, :username)
  end
end
