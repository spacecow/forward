Forward::Application.routes.draw do
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'admin_logout' => 'sessions#destroy', :as => :admin_logout
  match 'admin_login' => 'sessions#new', :as => :admin_login

  resources :sessions

  resources :users

  resources :locales, :only => [:create,:update]
  resources :translations, :only => [:index,:create] do
    collection do
      delete 'delete'
    end
  end

  match 'edit' => 'operator#edit'
  match 'login' => 'operator#login'
  match 'logout' => 'operator#logout'
  match 'connect' => 'operator#connect'
  match 'update' => 'operator#update'
  
  get "operator/logout"
  get "operator/edit"
  get "operator/login"
  post "operator/connect"
  post "operator/update"
  root :to => "operator#login"
end
