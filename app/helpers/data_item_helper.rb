module DataItemHelper
  def create_item_link item
    if item.is_a? DirectoryItem 
      if item.directory_type == :users_directory
        shares_index_path
      else
        url_for({ only_path: true,
          controller: :directory, 
          action: :index, 
          # генерация пути вида /home/... если текущий пользователь является владельцем
          user_name: item.owner.name == current_user.name ? nil : item.owner.name, 
          path: item.path.to_s_non_rooted
        })
      end
    else
      url_for({ only_path: true,
        controller: :file, 
        action: :get, 
        user_name: item.owner.name, 
        path: item.path.to_s_non_rooted
      })
    end
  end

  def create_item_preview_link item, size = "24x24"
    if item.type == 'image'
      original_url = url_for({ only_path: true,
        controller: :file, 
        action: :preview, 
        user_name: item.owner.name, 
        path: item.path.to_s_non_rooted,
        size: size
      })
      preview = PreviewManager.get item, size
      if (preview[:exist])
        {
          url: original_url,
          exist: true
        }
      else
        {
          url: ActionController::Base.helpers.asset_path('spinner.gif'),
          exist: false,
          statusUrl: url_for({ only_path: true,
            controller: :file, 
            action: :preview, 
            user_name: item.owner.name, 
            path: item.path.to_s_non_rooted,
            size: size,
            status: true
          }),
          originalUrl: original_url
        }
      end
    else
      if Settings.type_images.include? item.type
        path = Settings.type_images[item.type]
      else
        path = Settings.type_images.other
      end
      {
        url: ActionController::Base.helpers.asset_path(path),
        exist: true
      }
    end
  end
end