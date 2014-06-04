class Settings::SecurityController < ApplicationController
  layout "settings"
  
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    old_password = params[:user][:old_password]
    if (!@user.authenticate old_password)
      flash[:error] = t 'errors.invalid_password' 
    else
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if (@user.valid?)
        @user.save!
        flash[:notice] = t '.security_updated'
      end
    end
    render 'edit' 
  end
end
