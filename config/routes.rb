Forward::Application.routes.draw do
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'admin_logout' => 'sessions#destroy', :as => :admin_logout
  match 'admin_login' => 'sessions#new', :as => :admin_login

  resources :sessions, :only => [:new,:create,:destroy]

  resources :users, :only =>[:edit,:update]

  resources :locales, :only => [:create]
  resources :translations, :only => [:index,:create] do
    collection do
      delete 'delete'
    end
  end

  namespace "procmail" do
    resources :filters
  end

  match 'edit'     => 'operator#edit'
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  #match 'login'    => 'operator#login'
  #match 'logout'   => 'operator#logout'
  match 'connect'  => 'operator#connect'
  match 'update'   => 'operator#update'
  match 'welcome'  => 'operator#login'
  match 'procmail' => 'operator#procmail'
  
  get "operator/logout"
  get "operator/edit"
  get "operator/login"
  post "operator/connect"
  post "operator/update"
  root :to => "operator#login"
end
