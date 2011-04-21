Forward::Application.routes.draw do
  get "operator/login"
  post "operator/connect"
  root :to => "operator#login"
end
