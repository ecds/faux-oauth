Rails.application.routes.draw do
  get "/auth/:provider/callback", to: "tokens#create"
  get "/auth/failure", to: "tokens#fail"
  post "/tokens", to: "tokens#verify"
  post "/tokens/revoke", to: "tokens#destroy"

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"

  get "/register", to: "registrations#new", as: :register
  post "/register", to: "registrations#create"

  get "/confirm/:token", to: "confirmations#show", as: :confirm
  get "/confirmation/resend", to: "confirmations#new", as: :new_confirmation
  post "/confirmation/resend", to: "confirmations#create"

  get "/password/reset", to: "passwords#new", as: :new_password
  post "/password/reset", to: "passwords#create"
  get "/password/reset/:token/edit", to: "passwords#edit", as: :edit_password
  patch "/password/reset/:token", to: "passwords#update", as: :password

  get "/up", to: "health_check#show"
end
