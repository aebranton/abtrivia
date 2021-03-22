Rails.application.routes.draw do
  root "pages#home"
  
  # Registration page and create action
  get 'register', to: 'player#new'
  post 'register', to: 'player#create'
  
  # Players history page
  get 'player_history', to: 'player#show'
  
  # Login routes and logout rout
  get '/login', to: 'logins#new'
  post '/login', to: 'logins#create'
  get '/logout', to: 'logins#destroy'
  
  # Some trivia session routes - allowing you to join next available, create auto game, custom game, and view the game page
  get '/trivia_session/any', to: 'trivia_session#join_any'
  get 'trivia_session/new'
  get 'trivia_session/create'
  get 'trivia_session/show'
  
  get 'new_custom', to: 'trivia_session#new_custom'
  post 'create_custom', to: 'trivia_session#create_custom'
 
  # Answer submission route in-game
  post '/submit_answer', to: 'player_answer#create'

  get 'pages/home'
end
