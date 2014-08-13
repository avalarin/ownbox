class FileController < ItemsController
  before_filter :authorize
  before_action :initialize_item

  def get
    File.open(item.full_path) do |f|
      send_data f.read, disposition: 'attachment'
    end
  end

  def preview
    size = params[:size] || "24x24"
    preview = PreviewManager.get item, size
    return render_api_resp :ok, data: { exist: false } unless preview[:exist]
    return render_api_resp :ok, data: { exist: true } if params[:status] == 'true'
    send_file preview[:path], type: 'image/png', disposition: 'inline'
  end

  def upload
    file = params[:file]
    uploaded = service.upload_file item.path, file
    render_api_resp :ok
  end
  
end