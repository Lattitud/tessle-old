Tessle::Application.routes.draw do
  # Remove www. from beginning of url
  constraints subdomain: 'www' do
    get ':any', to: redirect(subdomain: nil, path: '/%{any}'), any: /.*/
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks", registrations: "registrations"}
  
  devise_scope :user do
    get "login", to: 'devise/sessions#new'
    get "signup", to: "devise/registrations#new"
    delete "signout", to: 'devise/sessions#destroy'
    post 'users/avatar' => 'registrations#update_avatar'
    # get "edit_avatar", to: 'devise/registrations#edit_avatar'
    # put "/confirm" => "confirmations#confirm"
  end

  # Navigates /users/1/favorites,following,followers
  resources :users do
    member do
      get :private, to: "private_messages#private"
      get :following, :followers
      get :tags
      get :chatted
      get :private_chat, to: "private_messages#private_chat"
      get :remove_chat, to: 'private_messages#remove_chat'
    end
  end
  
  # These are controller helper methods for Posts
  get "posts/tags" => "posts#tags", as: :tags
  post "posts/preview" => "posts#preview"
  get 'tags/:tag', to: 'posts#index', as: :tag

  # Navigates /posts/1
  resources :posts do #, only: [:index, :new, :show, :create, :destroy] do
    resources :messages
    member do
      get :chat, to: "messages#chat"
    end
  end

  resources :messages
  resources :private_messages

  # resources :sessions, only: [:new, :create, :destroy]
  resources :user_relationships, only: [:create, :destroy]
  resources :tessle_relationships, only: [:create, :destroy]

  root to: 'static_pages#home'

  # get '/help',    to: 'static_pages#help'
  # get '/about',   to: 'static_pages#about'
  # get '/contact', to: 'static_pages#contact'
  # get '/welcome', to: 'static_pages#welcome'
  # get '/stats', to: 'static_pages#stats'

  post 'pusher/auth'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
