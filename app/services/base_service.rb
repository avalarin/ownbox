class BaseService
  
  attr_accessor :current_user, :params

  include ::Errors

  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params.dup if params
  end

end