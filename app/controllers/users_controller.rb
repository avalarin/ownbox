class UsersController < ApplicationController

  def index
    @users = User.all
    respond_to do |format|
      format.json { render :json => wrap_users(@users).to_json }
    end
  end
  
  def show
    @user = User.find_by_name params[:name]
    return render_not_found unless @user
    
    respond_to do |format|
      format.json { render :json => wrap_user(@user).to_json }
    end
  end

  private

  def wrap_users users
    users.collect { |u| wrap_user u } 
  end

  def wrap_user u
    {
      name: u.name,
      displayName: u.display_name,
      email: u.email
    }
  end

end