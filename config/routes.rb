Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/internal/graphql"
  end

  devise_for :users
  root 'pages#index'
  get 'privacy-policy' => 'pages#privacy_policy'
  get 'contact' => 'pages#contact'
  get 'about' => 'pages#about'
  get 'term' => 'pages#term'
  get 'sitemap' => 'pages#sitemap'
  get 'component-library' => 'pages#component_library' if Rails.env.development?

  resources :categories, only: %i(index show) do
    collection do
      get ':cat1/:cat2', action: :show
      get ':cat1/:cat2/:cat3', action: :show
    end
  end

  resources :movies, only: %i(show)

  resources :video_artists, path: 'youtubers', only: %i(index show)

  resources :music, only: %i(index show) do
    collection do
      get ':cat2', action: :show
      get ':cat2/:cat3', action: :show
    end
  end

  resources :search, only: :index

  namespace :spots do
    resources :categories, only: %i(index show) do
      collection do
        get ':cat2', action: :show
        get ':cat2/:cat3', action: :show
      end
    end
  end

  namespace :internal do
    namespace :api do
      get :movie_location
    end
    post 'graphql', to: "graphql#execute"
  end

  namespace :admin do
    resources :movies, only: %i(index show create update)
    resources :featured_movies, only: %i(index show create update)
    resources :categories, only: %i(index show create update) do
      post :sort
      collection do
        post :sort_root_category
        get 'sort', action: :index_sort
        get 'dashboard', action: :index_dashboard
      end
      member do
        get 'sort', action: :show_sort
      end
    end
    resources :video_artists, only: %i(show update) do
      collection do
        get :sns
        get :manager
        put :update_latest_published_at
      end
    end
    resources :advertisements, only: %i(index create update)
    namespace :api do
      get :movies
      get :movie_info
      get :movie_exists
      get :children_categories
      post :video_artist
    end
  end

  get '/404' => 'errors#render_404'
  get '/500' => 'errors#render_500'

  get 'sys/health_check' => Proc.new { [200, {'Content-Type' => 'text/plain'}, ['healty']] }

  # For Routing Error
  get '*path', controller: 'application', action: 'render_404'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
