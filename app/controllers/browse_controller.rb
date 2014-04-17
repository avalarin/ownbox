class BrowseController < ApplicationController
  include DataItemHelper
  attr_reader :target_user, :item_path, :service, :item
  before_filter :authorize
  before_action do
    @target_user = get_user
    @item_path = get_path
    @service = DataService.new current_user, target_user 
    @item = service.get_item item_path

    if !@item
      render_not_found
      false
    end
  end

  def index
    return render_not_found if item.type != 'directory'
    @items = service.get_items item_path
    @path_parts = get_path_parts item_path
    @current_directory = item_path
  end

  def get
    File.open(item.full_path) do |f|
      send_data f.read, disposition: 'attachment'
    end
  end

  def preview
    preview = service.get_item_preview item.path
    send_data preview.data, disposition: 'attachment'
  end

  private

  def get_user
    if (params['user_name'] == :current_user)
      current_user
    else
      User.find_by_name(params['user_name'])
    end
  end

  def get_path
    path = params['path'] || ''
    path[0] = '' if path[0] == '/'
    path
  end

  def get_path_parts path
    parts = [ { name: icon('home'), path: '/', url: create_part_link(''), active: false } ]
    current = ''
    path.split('/').each do |part|  
      current += part;
      parts.push({
        name: part,
        path: current,
        url: create_part_link(current), 
        active: false
      })
      current += '/'
    end
    parts[-1][:active] = true
    parts
  end

  def create_part_link path
    url_for({ controller: :browse, 
      action: :index, 
      user_name: nil, 
      path: path
    })
  end

end