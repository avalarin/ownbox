module Admin
  class HomeController < AdminBaseController
    def index
      redirect_to admin_users_index_path
    end
  end
end