FilesBrowser::Application.routes.draw do
  root 'home#index'

  get '/login', to: 'session#new', as: :login
  post '/login', to: 'session#create', as: :login_post
  get '/logout', to: 'session#destroy', as: :logout

  get '/register', to: 'registration#new', as: :register_user
  post '/register', to: 'registration#create', as: :create_user
  get '/register/success', to: 'registration#success', as: :register_user_success
  get '/register/activate', to: 'registration#activate', as: :activate_user

  get '/get/:user_name(/*path)', to: 'file#get', as: :get_item, :format => false
  get '/preview/:user_name(/*path)', to: 'file#preview', as: :preview_item, :format => false

  get '/home(/*path)', to: 'directory#index', defaults: { user_name: :current_user }, as: :current_user_items_index, :format => false
  get '/shares/(:user_name(/*path))', to: 'directory#index', as: :shares_index, :format => false

  post '/directory/create', to: 'directory#create'
  get '/directory/deleteModal', to: 'directory#delete_modal'
  post '/directory/destroy', to: 'directory#destroy'

  post '/file/upload', to: 'file#upload'

  get '/users', to: 'users#index', as: :users_index
  get '/users/:name', to: 'users#show', as: :show_user

  namespace :settings do
    get '/profile', to: 'profile#edit', as: :edit_profile
    patch '/profile', to: 'profile#update', as: :update_profile

    get '/shares', to: 'shares#index', as: :shares_index
    post '/shares', to: 'shares#create', as: :create_share
    patch '/shares', to: 'shares#update', as: :update_share
    delete '/shares', to: 'shares#delete', as: :delete_share

    get '/shares/:share_id/permissions/', to: 'share_permissions#index', as: :share_permissions_index
    patch '/shares/:share_id/permissions/', to: 'share_permissions#update', as: :update_share_permissions

    get '/security', to: 'security#edit', as: :edit_security
    patch '/security', to: 'security#update', as: :update_security
  end

  namespace :admin do
    get '/', to: 'home#index', as: :home

    get '/users', to: 'users#index', as: :users_index
    post '/users', to: 'users#create', as: :create_user
    post '/users/:user_name/send_email', to: 'users#send_activation_email', as: :send_user_activation_email
    patch '/users/:user_name', to: 'users#update', as: :update_user

    get '/invites', to: 'invites#index', as: :invites_index
    post '/invites', to: 'invites#create', as: :create_invite
    delete '/invites/:code', to: 'invites#delete', as: :delete_invite
  end

end
