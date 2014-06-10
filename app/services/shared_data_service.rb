class SharedDataService < BaseDataService
    attr_reader :target_user

    def initialize current_user, target_user, params = {}
    super current_user, params

    if target_user
      @target_user = target_user
      create_directory_if_not_exists home_directory
    else
      @target_user = nil
    end
  end

  def get_item path
    unless target_user
      return DirectoryItem.new({
        directory_type: :users_directory,
        name: nil,
        path: Path.new([], rooted: true),
        full_path: nil,
        owner: current_user,
        permission: :readonly
      })
    end 
    if path.parts.length == 0
      return DirectoryItem.new({
        directory_type: :shares_directory,
        name: target_user.name,
        path: path,
        full_path: home_directory,
        owner: target_user,
        permission: :readonly
      })
    end
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    return nil unless share
    return share if path.parts.length == 1
    item_full_path = get_full_path_for_share share, path_in_share
    item_name = File.basename(item_full_path)
    item_name = target_user.name if (item_name.strip == '') 
    get_item_safe item_full_path, path, item_name, target_user, share.permission
  end

  def get_items path
    return get_users unless target_user
    return get_shares if path.is_empty?
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    return nil unless share
    item_full_path = get_full_path_for_share share, path_in_share
    get_items_safe item_full_path, path
  end

  def get_path_parts path
    users_part = DirectoryItem.new({
        directory_type: :users_directory,
        name: nil,
        path: Path.new([], rooted: true),
        full_path: nil,
        owner: current_user,
        permission: :readonly
      })
    parts = [ users_part ]
    return parts unless target_user
    parts.push(DirectoryItem.new({
      directory_type: :shares_directory,
      name: nil,
      path: Path.new([], rooted: false),
      # full_path: item_full_path,
      owner: target_user,
      permission: :readonly
    }))
    current = ''
    share_name = path.parts[0]
    return parts if !share_name || share_name.empty?

    if path.parts.length
      
      share = get_share share_name

      raise ::Errors::NotFoundError, "Share not found" unless share

      path.parts.each do |part|  
        current += part;
        parts.push(DirectoryItem.new({
          name: part,
          path: Path.parse(current),
          # full_path: item_full_path,
          owner: target_user,
          permission: share.permission
        }))
        current += '/'
      end
    end
    parts
  end

  def get_item_preview path, size = 24
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    raise AccessDeniedError, "Access denied" unless share
    item_full_path = get_full_path_for_share share, path_in_share
    get_item_preview_safe item_full_path, size
  end

  def create_directory path, name
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    raise AccessDeniedError, "Access denied" unless share && share.permission == :readwrite
    item_full_path = get_full_path_for_share share, path_in_share
    create_directory_safe item_full_path, name
  end

  def upload_file path, file
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    raise AccessDeniedError, "Access denied" unless share && share.permission == :readwrite
    item_full_path = get_full_path_for_share share, path_in_share
    upload_file_safe item_full_path, file
  end

  def delete_directory path, recursive = false
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    raise AccessDeniedError, "Access denied" unless share && share.permission == :readwrite
    item_full_path = get_full_path_for_share share, path_in_share
    delete_directory_safe item_full_path, recursive
  end

  def delete_file path
    share_name, path_in_share = split_shared_path path
    share = get_share share_name
    raise AccessDeniedError, "Access denied" unless share && share.permission == :readwrite
    item_full_path = get_full_path_for_share share, path_in_share
    delete_file_safe item_full_path
  end

  private

  def home_directory
    require_target_user
    target_user.full_home_directory
  end

  def get_share name
    require_target_user
    permission = SharePermission.joins(:share)
                  .where("share_permissions.user_id = ? and shares.user_id = ? and shares.name = ?", current_user.id, target_user.id, name)
                  .limit(1)[0]
    return nil unless permission
    share = permission.share
    item = DirectoryItem.new({
      name: share.name,
      path: Path.new([ share.name ], rooted: true),
      full_path: get_full_path(target_user.full_home_directory, share.path),
      owner: target_user,
      permission: permission.permission.to_sym
    })
  end  

  def get_shares
    require_target_user
    SharePermission.joins(:share)
      .where("share_permissions.user_id = ? and shares.user_id = ?", current_user.id, target_user.id)
      .map do |permission|
        share = permission.share
        DirectoryItem.new({
          name: share.name,
          path: Path.new([ share.name ], rooted: true),
          full_path: get_full_path(target_user.full_home_directory, share.path),
          owner: target_user,
          permission: permission.permission.to_sym
        })
      end
  end

  def get_users
    SharePermission.where(user_id: current_user.id)
      .collect { |share| share.share.user }
      .uniq
      .map do |user|
        DirectoryItem.new({
          directory_type: :shares_directory,
          name: nil,
          path: Path.new([ ], rooted: true),
          full_path: Path.parse(user.full_home_directory),
          owner: user,
          permission: :readonly
       })
      end
  end

  def require_target_user
    raise ArgumentError, 'target_user is required' unless target_user
  end

  def split_shared_path path
    share_name = path.parts[0]
    path_in_share = Path.new(path.parts.slice(1, path.parts.length - 1), rooted: false)
    return share_name, path_in_share
  end


  def get_full_path_for_share share, path_in_share
    File.join share.full_path, path_in_share
  end

end