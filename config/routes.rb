Rails.application.routes.draw do
  # resources :clients
  # resources :tokens
  get "/auth/:provider/callback", to: "tokens#create"
  get "/auth/failure", to: "tokens#fail"
  post "/tokens", to: "tokens#verify"
  post "/tokens/revoke", to: "tokens#destroy"
  get "/up", to: "health_check#show"
end
