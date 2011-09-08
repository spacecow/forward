Forward::Application.routes.draw do
  match 'user/edit' => 'users#edit', :as => :edit_current_user

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
  match 'procmail', :controller => "procmail/filters", :action => "index"

  namespace "forward" do
  end

  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  match 'welcome'  => 'sessions#new'
  
  match 'forward/edit' => 'operator#edit'
  match 'forward/connect'  => 'operator#connect'
  match 'forward/update'   => 'operator#update'
  get "operator/edit"
  post "operator/connect"
  post "operator/update"
  root :to => "sessions#new"
end
