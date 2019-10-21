Rails.application.routes.draw do
  # resources :clients
  # resources :tokens
  get '/auth/:provider/callback', to: 'tokens#create'
  post '/tokens', to: 'tokens#verify'
end
