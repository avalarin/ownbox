class RegistrationController < ApplicationController

  before_filter do
    if (Settings.security.registration_mode == :disabled)
      render_not_found
      false
    end
  end

  def new
    @user = User.new
    @captcha = Captcha::Data.generate
    @captcha.save
  end

  def create
    return render_api_resp :bad_request, message: 'invalid_captcha' unless captcha_valid?
    
    invite = nil
    if Settings.security.registration_mode == :invites
      invite = Invite.find_by_code params.require(:invite)
      if (!invite || invite.activated)
        return render_api_resp :bad_request, message: 'invalid_invite'
      end
    end
    params.require(:user).permit! #(:name, :display_name, :email, :password)
    user = User.new params[:user]
    user.password_confirmation = user.password
    user.activation_code = SecureRandom.uuid
    if user.valid?
      user.save!
      if invite
        invite.activated = true
        invite.user = user
        invite.save!
      end
      UserMailer.success_registration(user).deliver
      render_api_resp :ok
    else
      render_model_errors_api_resp user
    end
  end

  def success

  end

  def check_invite
    return render_api_resp :bad_request, message: 'invalid_captcha' unless captcha_valid?

    invite = Invite.find_by_code params.require(:invite)
    if (invite && !invite.activated)
      render_api_resp :ok
    else
      return render_api_resp :bad_request, message: 'invalid_invite'
    end
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