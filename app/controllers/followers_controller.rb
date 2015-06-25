class FollowersController < ApplicationController
  before_action :logged_in_user, only: :index
  
  def index
    @title = t :follow
    @user = User.find params[:id]
    @users = @user.followers.paginate page: params[:page], per_page: Settings.length.page
    render "show_follow"
  end
end