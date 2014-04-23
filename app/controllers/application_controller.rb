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
      if request.xhr?
        render_api_resp :unauthorized, data: {
          login_page: login_path
        }
      else
        redirect_to login_path
      end
      false
    end
  end
end
