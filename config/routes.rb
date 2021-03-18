Rails.application.routes.draw do
  root "pages#home"

  get 'register', to: 'player#new'
  post 'register', to: 'player#create'
  get 'playerhistory', to: 'player#show'


  get '/login', to: 'logins#new'
  get '/logout', to: 'logins#destroy'
  post '/login', to: 'logins#create'
  
  get 'pages/home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
