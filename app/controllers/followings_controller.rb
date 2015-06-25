class FollowingsController < ApplicationController
  before_action :logged_in_user, only: :index

  def index
    @title = t :following
    @user = User.find params[:id]
    @users = @user.following.paginate page: params[:page], per_page: Settings.length.page
    render "show_follow"
  end
end