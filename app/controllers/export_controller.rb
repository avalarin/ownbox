class ExportController < ItemsController
  before_filter :authorize
  before_action :initialize_item, only: :begin

  def begin
    filter = params[:filter] || []
    filter = [ filter ] unless filter.is_a? Array

    return render_api_resp :bad_request if filter.any? do |f|
      f =~  /(\/|\\|\A)\.+(\/|\\|\Z)/
    end 

    result = Ziper.create(current_user, item, filter)
    render_api_resp :ok, data: result
  end

  def status
    id = params.require(:id)
    status = Ziper.status(current_user, id)
    render_api_resp :ok, data: status
  end

  def result
    id = params.require(:id)
    status = Ziper.status(current_user, id)
    if (status[:status] == :not_found)
      return render_api_resp :not_found, message: 'Not found.'
    end
    if (status[:status] != :completed)
      return render_api_resp :not_found, message: 'Not completed.'
    end
    result = Ziper.get(current_user, id)
    send_file result[:path], type: 'application/zip', disposition: 'inline', filename: result[:filename]
  end

  def delete
    id = params.require(:id)
    status = Ziper.status(current_user, id)
    if (status[:status] == :not_found)
      return render_api_resp :not_found
    end
    Ziper.delete(current_user, id)
    return render_api_resp :ok
  end

end