class DirectoryController < ItemsController

  def index
    return render_not_found if item.type != 'directory'
    if  request.xhr?
      items = service.get_items(item_path).collect { |i| collect_item i }
      render json: { items: items, path: get_path_parts(item_path) }
    else
      @items = service.get_items item_path
      @path_parts = get_path_parts item_path
      @current_item = collect_item item
    end
  end

  def create
    new_name = params[:name]
    if (!new_name || new_name.strip! == '')
      render_api_resp :not_acceptable, message: t('errors.messages.directory_name_cannot_be_empty')
      return
    end
    service.create_directory(item.path, new_name)
    render_api_resp :ok
  end

  def destroy
    names = params[:name].split(',')
    return render_api_resp :not_acceptable if (names.length == 0) 

    items_for_deletion = []
    names.each do |n|
      item_for_deletion = service.get_item File.join item.path, n
      return render :not_found, message: 'Item not found: #{n} in #{item.path}' if !item_for_deletion
      items_for_deletion.push item_for_deletion
    end
    items_for_deletion.each do |item_for_deletion| 
      if (item_for_deletion.type == 'directory')
        service.delete_directory item_for_deletion.path, true
      else
        service.delete_file item_for_deletion.path
      end
    end
    render_api_resp :ok
  end

  private

  def get_path_parts path
    parts = [ { name: target_user.name, path: '/', url: create_part_link(''), type: 'directory' } ]
    current = ''
    path.split('/').each do |part|  
      current += part;
      parts.push({
        name: part,
        path: current,
        url: create_part_link(current), 
        type: 'directory', 
      })
      current += '/'
    end
    parts[-1][:active] = true
    parts
  end

  def create_part_link path
    url_for({ only_path: true,
      controller: :directory, 
      action: :index, 
      user_name: nil, 
      path: path
    })
  end
  
  def collect_item item
    nitem = {
      name: item.name,
      path: item.path,
      owner: item.owner.name,
      type: item.type,
      url: create_item_link(item),
      preview_url: ActionController::Base.helpers.asset_path(create_item_preview_link(item, 24))
    }
    if (item.type != 'directory')
      nitem['size'] = item.size;
      nitem['human_size'] = item.human_size;
    else
      nitem['size'] = 0;
      nitem['human_size'] = "";
    end
    nitem
  end

end