PivotalDashboard::Application.routes.draw do
  root :to => "welcome#index"

  match 'team' => 'team#index'

  resources :people
  
  match 'admin' => 'admin/root#index'

  namespace :admin do
    resources :teams
  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
