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
  get '/browse/:user_name(/*path)', to: 'directory#index', as: :user_items_index, :format => false

  post '/directory/create', to: 'directory#create'
  get '/directory/deleteModal', to: 'directory#delete_modal'
  post '/directory/destroy', to: 'directory#destroy'

  post '/file/upload', to: 'file#upload'

  namespace :settings do
    get '/profile', to: 'profile#edit', as: :edit_profile
    patch '/profile', to: 'profile#update', as: :update_profile
  end

end
