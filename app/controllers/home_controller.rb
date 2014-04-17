class HomeController < ApplicationController
  def index
    if authenticated?
      return redirect_to controller: 'browse', action: 'index'
    else
    end
  end
end
