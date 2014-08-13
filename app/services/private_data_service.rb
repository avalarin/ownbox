class PrivateDataService < BaseDataService

  def initialize current_user, params = {}
    super current_user, params
    create_directory_if_not_exists home_directory
  end

  def get_item path
    full_path = File.join home_directory, path
    item_name = File.basename(full_path)
    item_name = current_user.name if (item_name.strip == '') 
    get_item_safe full_path, path, item_name, current_user, :readwrite
  end

  def get_items path
    full_path = File.join home_directory, path
    get_items_safe full_path, path, current_user, :readwrite
  end

  def get_path_parts path
    home_part = DirectoryItem.new({
      directory_type: :home_directory,
      name: nil,
      path: Path.new([], rooted: false),
      # full_path: item_full_path,
      owner: current_user,
      permission: :readwrite
    })
    parts = [ home_part ]
    current = ''
    path.parts.each do |part|  
      current += part;
      parts.push(DirectoryItem.new({
        name: part,
        path: Path.parse(current),
        # full_path: item_full_path,
        owner: current_user,
        permission: :readwrite
      }))
      current += '/'
    end
    parts
  end

  def create_directory path, name
    item = get_item path
    raise Errors::NotFoundError, "Directory #{path} not found" unless item && item.is_a?(DirectoryItem)

    create_directory_safe item.full_path, name
  end

  def upload_file path, file
    item = get_item path
    raise Errors::NotFoundError, "Directory #{path} not found" unless item && item.is_a?(DirectoryItem)

    upload_file_safe item.full_path, file
  end

  def delete_directory path, recursive = false
    item = get_item path
    raise Errors::NotFoundError, "Directory #{path} not found" unless item && item.is_a?(DirectoryItem)

    delete_directory_safe item.full_path, recursive
  end

  def delete_file path
    item = get_item path
    raise Errors::NotFoundError, "File #{path} not found" unless item && item.is_a?(FileItem)

    delete_file_safe item.full_path
  end

  private

  def home_directory
    current_user.full_home_directory
  end

end