class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include HtmlHelper
  include SessionHelper
  include RenderHelper

  def authorize
    unless authenticated?
      flash[:error] = t 'errors.messages.access_denied'
      redirect_to login_path
      false
    end
  end
end
