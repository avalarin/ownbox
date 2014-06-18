class FileController < ItemsController
  before_filter :authorize

  def get
    File.open(item.full_path) do |f|
      send_data f.read, disposition: 'attachment'
    end
  end

  def preview
    preview = service.get_item_preview item.path
    send_data preview.data, disposition: 'attachment'
  end

  def upload
    file = params[:file]
    uploaded = service.upload_file item.path, file
    render_api_resp :ok
  end
  
end