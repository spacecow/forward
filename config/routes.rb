Forward::Application.routes.draw do
  get "operator/login"
  get "operator/connect"
  root :to => "operator#login"
end
