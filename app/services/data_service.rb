class DataService < BaseService
  attr_reader :target_user, :home_directory

  def initialize(current_user, target_user, params = nil)
    super current_user, params
    @target_user = target_user
    @home_directory = target_user.full_home_directory
    @use_shares = (@current_user.id != @target_user.id)

    check_home_directory_exists
  end

  def get_item path
    if @current_user.id == @target_user.id
      get_private_item path
    else
      get_shared_item path
    end
  end

  def get_items path
    if @current_user.id == @target_user.id
      get_private_items path
    else
      get_shared_items path
    end    
  end

  def get_path_parts path
    home_part = DirectoryItem.new({
      name: target_user.name,
      path: Path.new([], rooted: false),
      # full_path: item_full_path,
      owner: target_user
    })
    parts = [ home_part ]
    current = ''
    path.parts.each do |part|  
      current += part;
      parts.push(DirectoryItem.new({
        name: part,
        path: Path.parse(current),
        # full_path: item_full_path,
        owner: target_user
      }))
      current += '/'
    end
    parts
  end

  def get_item_preview path, size = 24
    item = get_item path
    preview = Preview.find_by_path item.full_path
    unless (preview)
      image = MiniMagick::Image.open(item.full_path)
      image.resize "#{size}x#{size}"
      preview = Preview.new({
        path: item.full_path,
        size: size,
        data: image.to_blob
      })
      preview.save
    end
    preview
  end

  def create_directory path, name
    item = get_item path
    raise IOError, "Directory #{path} does not exists." unless (item && item.type == 'directory')
    full_path = File.join item.full_path, name
    raise IOError, "Item #{full_path} already exists." if (File.exists? full_path)
    FileUtils.mkdir full_path
  end

  def upload_file path, file
    item = get_item path
    raise IOError, "Directory #{path} does not exists." unless (item && item.type == 'directory')

    file_name = file.original_filename
    full_path = File.join item.path, file_name
    iteration = 1
    while File.exists? full_path
      if (iteration == 1)
        extension = File.extname file.original_filename
        base_name = File.basename file.original_filename, extension
      end
      file_name = base_name + "_" + iteration.to_s + extension
      full_path = File.join item.path, file_name
      iteration += 1
    end
    File.open(full_path, 'wb') do |newfile|
      newfile.write(file.read)
    end
    get_item File.join path, file_name
  end

  def delete_directory path, recursive = false
    item = get_item path
    raise IOError, "Directory #{path} does not exists." unless (item && item.type == 'directory')
    if (recursive)
      FileUtils.rm_r item.full_path
    else
      raise IOError, "Directory #{path} is not empty." if Dir.entries(item.full_path).length > 0
      FileUtils.rmdir item.full_path
    end
  end

  def delete_file path
    item = get_item path
    raise IOError, "Directory #{path} does not exists." unless (item && item.type != 'directory')
    FileUtils.rm item.full_path
  end

  private

  def check_home_directory_exists
    FileUtils.mkdir_p @home_directory unless File.directory? @home_directory
  end

  def get_file_type extension
    Settings.file_types.each do |type, extensions|
      return type if extensions.include? extension
    end
  end

  def get_full_path path
    Path.parse(File.join home_directory, path.to_s)
  end

  def get_shared_item path
    if path.parts.length == 0
      return DirectoryItem.new({
        name: target_user.name,
        path: path,
        full_path: home_directory,
        owner: target_user
      })
    end
    share = get_share path.parts[0]
    return nil unless share
    return share if path.parts.length == 1
    path_in_share = Path.new(path.parts.slice(1, path.parts.length - 1), rooted: false)
    item_full_path = File.join share.full_path, path_in_share
    get_item_safe item_full_path, path
  end

  def get_private_item path
    full_path = File.join home_directory, path
    get_item_safe full_path, path
  end

  def get_item_safe full_path, item_path
    item_name = File.basename(full_path)
    item_name = target_user.name if (item_name.strip == '') 
    return nil unless File.exists? full_path
    if (File.directory? full_path)
      DirectoryItem.new({
        name: item_name,
        path: item_path,
        full_path: full_path,
        owner: target_user
      })
    else
      item_type = get_file_type(File.extname(item_name))
      FileItem.new({
        name: item_name,
        path: item_path,
        full_path: full_path,
        type: item_type,
        size: File.size(full_path),
        owner: target_user
      })
    end
  end

  def get_share name
    share = Share.find_by_user_and_name target_user, name
    return nil unless share
    DirectoryItem.new({
      name: share.name,
      path: Path.new([ share.name ], rooted: true),
      full_path: get_full_path(share.path),
      owner: target_user
    })
  end

  def get_shares
    Share.get_by_user(target_user)
      .map do |share|
        DirectoryItem.new({
          name: share.name,
          path: Path.new([ share.name ], rooted: true),
          full_path: get_full_path(share.path),
          owner: target_user
        })
       end
  end

  def get_shared_items path
    return get_shares if path.is_empty?
    share = get_share path.parts[0]
    return nil unless share
    path_in_share = Path.new(path.parts.slice(1, path.parts.length - 1), rooted: false)
    item_full_path = File.join share.full_path, path_in_share
    get_items_safe item_full_path, path
  end

  def get_private_items path
    full_path = File.join home_directory, path
    get_items_safe full_path, path
  end

  def get_items_safe full_path, path
    Dir.entries(full_path)
      .select { |item| item != '.' && item != '..' }
      .map do |item| 
        item_path = Path.parse(File.join path, item)
        get_item item_path
      end
      .sort do |a, b| 
        if a.type == b.type
          a.name <=> b.name
        else
          a.type == 'directory' ? -1 : 1
        end
      end
  end

end