class BaseService
  
  attr_accessor :current_user, :params

  def initialize(current_user, params = nil)
    @current_user = current_user
    @params = params.dup if params
  end

end