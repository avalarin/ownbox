module RenderHelper

  def render_not_found

    respond_to do |format|
      format.html { render :file => 'public/404.html', :status => :not_found, :layout => false }
      format.json { render_api_resp :not_found }
    end

    
  end

  def render_api_resp status, options = {}
    default_message = ''
    status_code = 0
    case status
    when :ok
      default_message = 'Ok'
      status_code = 200
    when :bad_request
      default_message = 'Bad Request'
      status_code = 400
    when :unauthorized
      default_message = 'Unauthorized'
      status_code = 401
    when :forbidden
      default_message = 'Forbidden'
      status_code = 403
    when :not_found
      default_message = 'Not Found'
      status_code = 404
    when :not_acceptable
      default_message = 'Not Acceptable'
      status_code = 406
    when :internal_server_error
      default_message = 'Internal Server Error'
      status_code = 500
    else
      raise ArgumentError, "Unknown status '#{ status.to_s }'"
    end
    render status: status_code, json: {
      status: status_code.to_s,
      message: options[:message] || default_message,
      data: options[:data]
    }
  end

  def render_model_errors_api_resp model
    render_api_resp :bad_request, message: 'validation_error', data: model.errors
  end

end