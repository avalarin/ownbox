class BaseDataService < BaseService

  def initialize current_user, params = {}
    super current_user, params
  end

  def get_item path
    raise NotImplementedException, 'Not implemented'
  end

  def get_items path
    raise NotImplementedException, 'Not implemented'
  end

  def get_path_parts path
    raise NotImplementedException, 'Not implemented'
  end

  def get_item_preview path, size = 24
    raise NotImplementedException, 'Not implemented'
  end

  def create_directory path, name
    raise NotImplementedException, 'Not implemented'
  end

  def upload_file path, file
    raise NotImplementedException, 'Not implemented'
  end

  def delete_directory path, recursive = false
    raise NotImplementedException, 'Not implemented'
  end

  def delete_file path
    raise NotImplementedException, 'Not implemented'
  end

  protected

  def create_directory_if_not_exists path
    FileUtils.mkdir_p path unless File.directory? path
  end

  def get_file_type extension
    Settings.file_types.each do |type, extensions|
      return type if extensions.include? extension.downcase
    end
    'other'
  end

  def get_full_path home_directory, path
    Path.parse(File.join home_directory, path.to_s)
  end

  def get_items_safe full_path, path, owner, permission = :unknown
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    raise ArgumentError, "path requried" unless path
    raise ArgumentError, "path must be Path" unless path.is_a? Path

    raise ArgumentError, "permission requried" unless permission

    dir_entries = Dir.entries(full_path).select { |name| name != '.' && name != '..' }
    db_entries = DataItem.includes(:shares).where(user_id: owner.id, path: dir_entries.map { |name| (path + name).to_s_rooted })
    db_entries.each do |item|
      item.permission = permission
      if (File.file? item.full_path)
        item.size = File.size(item.full_path)
        item.type = get_file_type(File.extname(item.full_path))
      end
    end

    nf_entries = (dir_entries - (db_entries.map { |i| i.name })).map do |name| 
      get_item_from_fs(File.join(full_path, name), path + name, name, owner, permission)
    end
    if nf_entries.count > 0
      DataItem.save_all(nf_entries)
      db_entries += nf_entries
    end
    db_entries.sort do |a, b| 
      if a.type == b.type
        a.name <=> b.name
      else
        a.type == 'directory' ? -1 : 1
      end
    end
  end

  def get_item_safe full_path, item_path, item_name, owner, permission = :unknown
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    raise ArgumentError, "item_path requried" unless item_path
    raise ArgumentError, "item_path must be Path" unless item_path.is_a? Path

    raise ArgumentError, "permission requried" unless permission

    return nil unless File.exists? full_path
    db_item = DataItem.find_by_user_and_path(current_user, item_path.to_s_rooted)
    if (!db_item)
      item = get_item_from_fs full_path, item_path, item_name, owner, permission
      item.save!
      return item
    else
      db_item.permission = permission
      if (File.file? full_path)
        db_item.size = File.size(full_path)
        db_item.type = get_file_type(File.extname(item_name))
      end
    end
    return db_item
  end

  def create_directory_safe full_path, name
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    raise ArgumentError, "name requried" if !name || name.empty? 

    full_path = File.join full_path, name
    raise IOError, "Item #{full_path} already exists." if (File.exists? full_path)
    FileUtils.mkdir full_path
  end

  def get_item_preview_safe full_path, size = 24
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    preview = Preview.find_by_path full_path
    unless (preview)
      image = MiniMagick::Image.open(full_path)
      image.resize "#{size}x#{size}"
      preview = Preview.new({
        path: full_path,
        size: size,
        data: image.to_blob
      })
      preview.save
    end
    preview
  end

  def upload_file_safe full_path, file
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    file_name = file.original_filename
    full_file_name = File.join full_path, file_name
    iteration = 1
    while File.exists? full_file_name
      if (iteration == 1)
        extension = File.extname file.original_filename
        base_name = File.basename file.original_filename, extension
      end
      file_name = base_name + "_" + iteration.to_s + extension
      full_file_name = File.join full_path, file_name
      iteration += 1
    end
    File.open(full_file_name, 'wb') do |newfile|
      newfile.write(file.read)
    end
  end

  def delete_directory_safe full_path, recursive = false
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    if (recursive)
      FileUtils.rm_r full_path
    else
      raise IOError, "Directory #{full_path} is not empty." if Dir.entries(full_path).length > 0
      FileUtils.rmdir full_path
    end
  end

  def delete_file_safe full_path
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    FileUtils.rm full_path
  end

  private 

  def get_item_from_fs full_path, item_path, item_name, owner, permission = :unknown
    raise ArgumentError, "full_path requried" unless full_path
    raise ArgumentError, "full_path must be String" unless full_path.is_a? String

    raise ArgumentError, "item_path requried" unless item_path
    raise ArgumentError, "item_path must be Path" unless item_path.is_a? Path

    raise ArgumentError, "permission required" unless permission

    data = {
      name: item_name,
      path: item_path,
      full_path: full_path,
      owner: owner,
      permission: permission
    }
    db_item = File.directory?(full_path) ? DirectoryItem.new(data) : FileItem.new(data)
    if (db_item.is_a? FileItem)
      db_item.size = File.size(full_path)
      db_item.type = get_file_type(File.extname(item_name))
    end
    db_item
  end

end