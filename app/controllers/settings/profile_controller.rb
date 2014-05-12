class Settings::ProfileController < ApplicationController
  layout "settings"
  
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.display_name = params[:user][:display_name]
    if (@user.valid?)
      @user.save!
      flash[:notice] = t '.profile_updated'
    end
    render 'edit' 
  end
end
