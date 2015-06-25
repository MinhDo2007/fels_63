class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :set_user, only: [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "login.success"
      redirect_to @user
    else
      render "new"
    end
  end

  def update
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password, :password_confirmation
  end

  def set_user
    @user = User.find params[:id]
  end

  def correct_user
    @users = User.find params[:id]
    redirect_to root_url unless current_user?(@user)
  end
end