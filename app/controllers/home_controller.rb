class HomeController < ApplicationController
  def index
    if authenticated?
      return redirect_to controller: :directory, action: :index
    else
    end
  end
end
