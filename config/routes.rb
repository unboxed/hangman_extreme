HangmanLeague::Application.routes.draw do
  get 'explain/:action', as: 'explain', controller: 'explain'

  resources :games, :except => [:edit, :update, :destroy] do
    collection do
      get 'play', action: 'play'
    end
    get 'page/:page', :action => :index, :on => :collection
    member do
      get 'show_clue', action: 'show_clue', as: 'show_clue'
      post 'show_clue', action: 'reveal_clue'
      get 'letter/:letter', action: 'play_letter', as: 'play_letter'
    end
  end
  resources :users, only: [:show, :index] do
    collection do
      get 'my_rank', action: 'show'
      get 'mxit_oauth', action: 'mxit_oauth', as: 'mxit_oauth'
      get 'hide_hangman', action: 'hide_hangman', as: 'hide_hangman'
      get 'show_hangman', action: 'show_hangman', as: 'show_hangman'
      get 'badges', action: 'badges', as: 'badges'
      get 'options', action: 'options'
    end
  end
  resources :feedback, :except => [:show, :edit, :update, :destroy]
  resources :winners, :except => [:edit, :update, :create, :new, :destroy]

  get '/define/:word', to: 'words#define', as: 'define_word'
  get '/auth/callback', to: 'sessions#create', as: 'create_session'
  get '/authorize', to: 'users#mxit_authorise', as: 'mxit_authorise'
  get '/about', to: 'explain#about', as: 'about'
  get '/terms', to: 'explain#terms', as: 'terms'
  get '/privacy', to: 'explain#privacy', as: 'privacy'
  get '/logout', to: 'sessions#destroy', as: 'logout'

  root :to => 'games#index'
end
