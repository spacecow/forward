Forward::Application.routes.draw do
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
