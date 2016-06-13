require 'sidekiq/web'

Rails.application.routes.draw do
  resources :diagnosis_images
  resources :buddis
  resources :ezer_readers
  resources :notifications
  resources :reports
  resources :users
  resources :specifications
  resources :error_codes
  resources :laboratories
  resources :quality_control_materials
  resources :assay_kits
  resources :reagents
  resources :plates
  resources :frends
  resources :diagnoses
  resources :equipment

#  get    'sessions/new'
#  get     'sessions/create'
#  delete  'sessions/destroy'

  # for ajax
  post    'qcm_dropdown' => 'qcm_dropdown#create'
  post    'ak_dropdown' => 'ak_dropdown#create'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'diagnoses#index'

  controller :sessions do
    get     'login'         => :new
    post    'login'         => :create
    delete  'logout'        => :destroy
  end
  
  controller :account_validations do
    get     'authorize'     => :inform
    post    'authorize'     => :resend
    get     'authorize/:id' => :confirm
  end

  controller :google_maps do
    get     'maps'    => :index
  end

  if Rails.env.development?
    # Sidekiq monitoring
    mount Sidekiq::Web, at: '/sidekiq'

    #  Letter Opener Web
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  
  # Notification response
  get '/responses/:id', to: 'responses#contact', as: 'response'

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
