Liquorlicensehq::Application.routes.draw do
  
  resources :criterias

  resources :license_types

  resources :user_details

  resources :liquor_license_auctions



  get "home/index"
  get "users/login"
  get "users/confirm"
  get "liquor_licenses/get_my_auction"
  get "users/import_data"
  get "liquor_licenses/get_cities"
  get "liquor_licenses/delete_record"
  get "liquor_licenses/accept"
  get "users/logout"
  get "users/check_criteria"
  get "criterias/delete_record"
  get "users/private"
  get "users/contact_us"
  get "home/search"
  get "users/sendmail_criteria_activity"
  get "users/forgot"
  get "users/sendmail"
  get "liquor_licenses/paypal_request"
  get "liquor_licenses/get_craigslist"
  get "liquor_licenses/get_for_sale"
  get "liquor_licenses/get_for_buy"
  get "liquor_licenses/get_for_both"
  get "users/check_bid"
  get "users/sendmail_bid_activity"
  resources :users
  resources :liquor_licenses



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
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
