class SessionController < ApplicationController
  
  def new
    if (authenticated?)
        redirect_to root_path
        return
    end
    @login = Login.new;
  end

  def create
    login = params[:login]
    user = User.find_by_email(login[:email])
    if (user)
        if (user.locked)
            flash.now.alert = t('errors.messages.user_locked')
        elsif (!user.approved)
            flash.now.alert = t('errors.messages.account_not_activated')
        elsif (!user.authenticate(login[:password]))
            flash.now.alert = t('errors.messages.invalid_email_or_password')
        else
          login_user user, login[:remember]
          redirect_to root_path
          return
        end
    else 
        flash.now.alert = t('errors.messages.invalid_email_or_password')
    end
    @login = Login.new(email: login[:email], remember: login[:remember])
    render 'new'
  end

  def destroy
    logout_user
    redirect_to login_path
  end

end