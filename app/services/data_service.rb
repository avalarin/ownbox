class DataService < BaseService
  attr_reader :target_user, :home_directory

  def initialize(current_user, target_user, params = nil)
    super current_user, params
    @target_user = target_user
    @home_directory = target_user.full_home_directory

    check_home_directory_exists
  end

  def get_item path
    item_full_path = File.join home_directory, path
    item_name = File.basename(path)
    item_name = target_user.name if (item_name.strip == '') 
    return nil unless File.exists? item_full_path
    if (File.directory? item_full_path)
      DirectoryItem.new({
        name: item_name,
        path: path,
        full_path: item_full_path,
        owner: target_user
      })
    else
      item_type = get_file_type(File.extname(item_name))
      FileItem.new({
        name: item_name,
        path: path,
        full_path: item_full_path,
        type: item_type,
        size: File.size(item_full_path),
        owner: target_user
      })
    end
  end


  def get_items path
    full_path = File.join home_directory, path
    Dir.entries(full_path)
      .select { |item| item != '.' && item != '..' }
      .map do |item| 
        item_path = File.join path, item
        item_path[0] = '' if item_path[0] == '/'
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
    full_path = File.join home_directory, path    
    raise IOError, "Directory #{full_path} does not exists." unless (File.directory? full_path)
    full_path = File.join full_path, name
    raise IOError, "Item #{full_path} already exists." if (File.exists? full_path)
    FileUtils.mkdir full_path
  end

  def upload_file path, file
    directory_path = File.join home_directory, path
    raise IOError, "Directory #{directory_path} does not exists." unless (File.directory? directory_path)
    file_name = file.original_filename
    full_path = File.join directory_path, file_name
    iteration = 1
    while File.exists? full_path
      if (iteration == 1)
        extension = File.extname file.original_filename
        base_name = File.basename file.original_filename, extension
      end
      file_name = base_name + "_" + iteration.to_s + extension
      full_path = File.join directory_path, file_name
      iteration += 1
    end
    File.open(full_path, 'wb') do |newfile|
      newfile.write(file.read)
    end
    get_item File.join path, file_name
  end

  def delete_directory path, recursive = false
    full_path = File.join home_directory, path
    raise IOError, "Directory #{full_path} does not exists." unless (File.directory? full_path)
    if (recursive)
      FileUtils.rm_r full_path
    else
      raise IOError, "Directory #{full_path} is not empty." if Dir.entries(full_path).length > 0
      FileUtils.rmdir full_path
    end
  end

  def delete_file path
    full_path = File.join home_directory, path
    raise IOError, 'Directory #{full_path} does not exists.' unless (File.file? full_path)
    FileUtils.rm full_path
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

end