Rails.application.routes.draw do
  devise_for :users
  root 'pages#index'

  resources :categories, only: %i(index show) do
    collection do
      get ':cat1/:cat2', action: :show
      get ':cat1/:cat2/:cat3', action: :show
    end
  end

  resources :video_artists, path: 'youtuber', only: %i(show)

  namespace :admin do
    resources :movies, only: %i(index show create update destroy)
    resources :categories, only: %i(index show create update) do
      post :sort
      collection do
        post :sort_root_category
        get 'sort', action: :index_sort
      end
    end
    resources :video_artists, only: %i(index show update)
    namespace :api do
      get :movie_info
      get :movie_exists
      post :video_artist
    end
  end

  get '/404' => 'errors#render_404'
  get '/500' => 'errors#render_500'
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
