module DataItemHelper
  def create_item_link item
    if item.type == 'directory' 
      url_for({ only_path: true,
        controller: :directory, 
        action: :index, 
        # генерация пути вида /home/... если текущий пользователь является владельцем
        user_name: item.owner.name == current_user.name ? nil : item.owner.name, 
        path: item.path.to_s_non_rooted
      })
    else
      url_for({ only_path: true,
        controller: :file, 
        action: :get, 
        user_name: item.owner.name, 
        path: item.path.to_s_non_rooted
      })
    end
  end

  def create_item_preview_link item, size = 24
    if item.type == 'image'
      url_for({ only_path: true,
        controller: :file, 
        action: :preview, 
        # генерация пути вида /home/... если текущий пользователь является владельцем
        user_name: item.owner.name == current_user.name ? nil : item.owner.name, 
        path: item.path.to_s_non_rooted
      })
    else
      if Settings.type_images.include? item.type
        Settings.type_images[item.type]
      else
        Settings.type_images.other
      end
    end
  end
end