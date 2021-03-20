Rails.application.routes.draw do
  root "pages#home"
  
  get 'register', to: 'player#new'
  post 'register', to: 'player#create'
  
  get 'player_history', to: 'player#show'
  
  get '/login', to: 'logins#new'
  get '/logout', to: 'logins#destroy'
  post '/login', to: 'logins#create'
  
  get '/trivia_session/any', to: 'trivia_session#join_any'
  get 'trivia_session/new'
  get 'trivia_session/create'
  get 'trivia_session/show'
  
  post '/submit_answer', to: 'player_answer#create'
  get '/test', to: 'player_answer#show'

  get 'pages/home'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
