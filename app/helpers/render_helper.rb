module RenderHelper

  def render_not_found
    render :file => 'public/404.html', :status => :not_found, :layout => false
  end

  def render_api_resp status, options = {}
    default_message = ''
    status_code = case status
    when :ok
      default_message = 'Ok'
      200
    when :bad_request
      default_message = 'Bad Request'
      400
    when :unauthorized
      default_message = 'Unauthorized'
      401
    when :forbidden
      default_message = 'Forbidden'
      403
    when :not_found
      default_message = 'Not Found'
      404
    when :not_acceptable
      default_message = 'Not Acceptable'
      406
    when :internal_server_error
      default_message = 'Internal Server Error'
      500
    else
      raise ArgumentError, "Unknown status '#{ status.to_s }'"
    end
    resp = {}
    resp['status'] = status_code
    resp['message'] = options[:message] || default_message
    resp['data'] = options[:data]
    render json: resp, status: status_code
  end

  def render_model_errors_api_resp model
    render_api_resp :bad_request, message: 'Invalid request', data: model.errors
  end

end