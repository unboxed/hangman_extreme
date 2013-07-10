HangmanLeague::Application.routes.draw do
  get "purchase_transactions", to: 'purchase_transactions#index', as: 'purchases'
  get "purchase_transactions/new", as: 'new_purchase'
  match "purchase_transactions/create", to: 'purchase_transactions#create', as: 'create_purchase'
  match "Transaction/PaymentRequest", to: 'purchase_transactions#simulate_purchase', as: 'mxit_purchase'
  get "explain/:action", as: 'explain', controller: 'explain'
  get "airtime_vouchers", to: 'airtime_vouchers#index', as: 'airtime_vouchers'

  resources :games, :except => [:edit, :update, :destroy] do
    collection do
      get 'play', action: "play"
    end
    get 'page/:page', :action => :index, :on => :collection
    member do
      get 'show_clue', action: "show_clue", as: 'show_clue'
      post 'show_clue', action: "reveal_clue"
      get "letter/:letter", action: 'play_letter', as: 'play_letter'
    end
  end
  resources :users, :except => [:create, :new, :destroy] do
    collection do
      get 'stats', action: "stats"
      get 'my_rank', action: "show"
      get 'mxit_oauth', action: 'mxit_oauth', as: 'mxit_oauth'
      get 'profile', action: 'profile', as: 'profile'
      get 'hide_hangman', action: 'hide_hangman', as: 'hide_hangman'
      get 'show_hangman', action: 'show_hangman', as: 'show_hangman'
      get 'badges', action: 'badges', as: 'badges'
    end
  end
  resources :feedback, :except => [:show, :edit, :update, :destroy]
  resources :winners, :except => [:edit, :update, :create, :new, :destroy]
  resources :redeem_winnings, :except => [:edit, :update, :destroy]

  match '/define/:word', to: 'words#define', as: 'define_word'
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/auth/:provider/failure', to: 'sessions#failure'
  match '/auth/failure', to: 'sessions#failure'
  match '/authorize', to: 'users#mxit_authorise', as: 'mxit_authorise'
  match '/about', to: 'explain#about', as: 'about'
  match '/terms', to: 'explain#terms', as: 'terms'
  match '/privacy', to: 'explain#privacy', as: 'privacy'
  match '/logout', to: 'sessions#destroy', as: 'logout'

  root :to => 'games#index'
end
