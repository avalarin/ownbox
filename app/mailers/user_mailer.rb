class UserMailer < BaseMailer

  def success_registration user
    @activation_url = activate_user_url code: user.activation_code
    mail to: user.email, subject: t('.mail_subject', app_name: Settings.app_name)
  end

end
