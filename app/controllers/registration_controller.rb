class RegistrationController < ApplicationController

  before_filter do
    if (Settings.security.registration_mode == :disabled)
      render_not_found
      false
    end
  end

  def new
    @user = User.new
  end

  def create
    params.require(:user).permit! #(:name, :display_name, :email, :password, :password_confirmation, :commit)
    @user = User.new params[:user]
    @user.activation_code = SecureRandom.uuid
    if @user.valid?
      @user.save!
      UserMailer.success_registration(@user).deliver
      redirect_to action: 'success'
    else
      render 'new'
    end
  end

  def success

  end

  def activate
    if params[:code]
      user = User.find_by_activation_code params[:code]
      if user
        user.approved = true
        user.activation_code = nil
        user.save!
        flash[:notice] = t '.account_activated'
      end
    end
    redirect_to login_path
  end

end