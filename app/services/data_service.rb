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
    return nil unless File.exists? item_full_path
    if (File.directory? item_full_path)
      DirectoryItem.new({
        name: item_name,
        path: path,
        full_path: item_full_path,
        owner: target_user
        # url: create_item_link(item_path),
        # image_path: get_item_image_path('directory')
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
        # url: create_item_link(item_path),
        # image_path: item_type == 'image' ? create_item_preview_link(item_path) : get_item_image_path(item_type)
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